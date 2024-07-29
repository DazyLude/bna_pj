@tool
@icon("res://assets/level_icon.svg")
extends Node2D
class_name GameLevel


enum CHARACTER_ID {
	ALTA, #0
	ARYA, #1
}


# coordinate system
const origin := Vector2(0., 0.);
const cell_size := Vector2(64., 64.);


func coords2position(coords: Vector2i) -> Vector2:
	return cell_size * Vector2(coords) + origin;


#region level data system
@export var level_terrain : TileMap = null;
# { coords: [object in this cell, object in this cell... ] }
var _objects_that_matter : Dictionary = {};
var _state_history : Dictionary = {};
var turn_number := 0;


func get_objects_by_tag(tag: LevelObject.TAGS) -> Array:
	var result : Array[LevelObject] = [];
	for coords in _objects_that_matter.keys():
		for obj in _objects_that_matter[coords]:
			if (obj as LevelObject).has_tag(tag):
				result.push_back(obj);
	return result;


func get_objects_by_tags(tags: Array[LevelObject.TAGS]) -> Array:
	var result : Array[LevelObject] = [];
	for coords in _objects_that_matter.keys():
		for obj in _objects_that_matter[coords]:
			for tag in tags:
				if (obj as LevelObject).has_tag(tag):
					result.push_back(obj);
					break;
	return result;


func get_objects_by_coords(coords: Vector2i) -> Array:
	return _objects_that_matter.get(coords, []);


func get_coords_of_an_object(object: LevelObject) -> Vector2i:
	for coords in _objects_that_matter.keys():
		for obj in _objects_that_matter[coords]:
			if obj == object:
				return coords;
	print_debug("object %s not found" % object);
	return Vector2i(0, 0);


func add_object(coords: Vector2i, object: LevelObject) -> void:
	if _objects_that_matter.has(coords):
		_objects_that_matter[coords].push_back(object);
	else:
		_objects_that_matter[coords] = [object];


func remove_object(coords: Vector2i, object: LevelObject) -> void:
	(_objects_that_matter[coords] as Array[LevelObject]).erase(object);
	if _objects_that_matter[coords].size() == 0:
		_objects_that_matter.erase(coords);


func move_object(move: MoveDTO) -> void:
	move.object.change_direction(Direction.from_vec(move.to - move.from));
	move.object.move_to(coords2position(move.to));
	remove_object(move.from, move.object);
	add_object(move.to, move.object);
#endregion


#region character system
signal changed_selected_character(CHARACTER_ID);
var selected_character : CHARACTER_ID = CHARACTER_ID.ARYA:
	set(new_value):
		changed_selected_character.emit(new_value);
		selected_character = new_value;
	get:
		return selected_character;


func move_character(direction_num: int) -> void:
	save_state();
	turn_number += 1;
	
	var direction := Direction.from_num(direction_num);
	match selected_character:
		CHARACTER_ID.ARYA:
			for arya in get_objects_by_tag(LevelObject.TAGS.ARYA):
				try_move(arya, direction);
		CHARACTER_ID.ALTA:
			for arya in get_objects_by_tag(LevelObject.TAGS.ALTA):
				try_move(arya, direction);
	
	process_lights();
	tick_turn();
	if check_win():
		go_next();

func save_state() -> void:
	for coords in _objects_that_matter.keys():
		for obj in _objects_that_matter[coords] as Array[LevelObject]:
			var gs := obj.get_state();
			gs["coords"] = coords;
			if _state_history.has(obj):
				_state_history[obj].push_back(gs);
			else:
				_state_history[obj] = [gs];


func load_state() -> void:
	_objects_that_matter.clear();
	for obj in _state_history.keys():
		var state = _state_history[obj].pop_back();
		obj.set_state(state);
		obj.move_to(coords2position(state["coords"]));
		add_object(state["coords"], obj);


func process_lights():
	update_beams();
	beam_on();
	var recursion_depth = 0;
	while recursion_depth < 10 && tick_light():
		update_beams();
		beam_on();
		recursion_depth += 1;


func check_win() -> bool:
	var characters = get_objects_by_tags([LevelObject.TAGS.ARYA, LevelObject.TAGS.ALTA]);
	var everyone_ready = true;
	for character in characters:
		if character.stuck:
			return false;
		var coords = get_coords_of_an_object(character);
		var other_objects = get_objects_by_coords(coords);
		var check = false;
		for obj in other_objects as Array[LevelObject]:
			if obj.has_tag(LevelObject.TAGS.WIN):
				check = true;
				break;
		if !check:
			everyone_ready = false;
	
	return everyone_ready;
#endregion


#region movement processing
class MoveDTO extends RefCounted:
	var object : LevelObject = null;
	var from := Vector2i(0, 0);
	var to := Vector2i(0, 0);
	
	
	func _init(_object: LevelObject, _from: Vector2i, _to: Vector2i) -> void:
		self.object = _object;
		self.from = _from;
		self.to = _to;


class MovementData extends RefCounted:
	var is_executable : bool = false;
	var objects_moved : Array[MoveDTO] = [];
	var weight : int = 1;
	
	func _init(who : LevelObject, from : Vector2i, to : Vector2i) -> void:
		is_executable = true;
		objects_moved = [MoveDTO.new(who, from, to)];
		if who.has_tag(LevelObject.TAGS.LIGHT):
			weight -= 1;
		if who.has_tag(LevelObject.TAGS.HEAVY):
			weight += 1;
	
	
	func add(another: MovementData) -> void:
		self.is_executable = self.is_executable && another.is_executable;
		self.objects_moved.append_array(another.objects_moved);
		self.weight += another.weight;


func check_move(object: LevelObject, from: Vector2i, to: Vector2i) -> MovementData:
	var movement = MovementData.new(object, from, to);
	for obj in get_objects_by_coords(to):
		# check tags of objects in the cell we're trying to move
		obj = obj as LevelObject;
		match [
			obj.has_tag(LevelObject.TAGS.STOP),
			obj.has_tag(LevelObject.TAGS.FLYING),
			object.has_tag(LevelObject.TAGS.FLYING)
		]:
			[true, true, _], [true, false, false]:
				# stop movement
				movement.is_executable = false;
				break;
		
		if obj.has_tag(LevelObject.TAGS.PUSH):
			# try to move object as well
			var obj_movement = check_move(obj, to, to * 2 - from);
			movement.add(obj_movement);
	
	# if the movement stack is too heavy, don't move at all
	if !(
		movement.weight <= 2 ||
		(movement.weight <= 3 && object.has_tag(LevelObject.TAGS.STRONG))
	):
		movement.is_executable = false;
	
	return movement;


func execute_move(move: MovementData) -> void:
	if !move.is_executable:
		return;
	
	for moveDTO in move.objects_moved:
		move_object(moveDTO);


func try_move(object: LevelObject, direction: Direction):
	var from := get_coords_of_an_object(object);
	var delta : Vector2i = direction.vec;
	var to = from + delta;
	
	var move := check_move(object, from, to);
	if move.is_executable && object.stuck != true:
		execute_move(move);
	else:
		object.nudge(coords2position(from), coords2position(to));
#endregion


#region light processing
var beams : Dictionary = {};
var beam_sensitive : Dictionary = {};

func calculate_beams(emitter: LevelObject, from: Vector2i) -> Dictionary:
	var end = from;
	var n_beams := {};
	for direction in emitter._get_emission_directions() as Array[Direction]:
		var type = emitter._get_emission_type(direction.num);
		if type == Beam.TYPE.NONE:
			continue;
		var delta : Vector2i = direction.vec;
		var length := 1;
		while length <= Beam.MAX_LENGTH:
			var potential_end = end + delta;
			for obj in get_objects_by_coords(potential_end) as Array[LevelObject]:
				if obj.has_tag(LevelObject.TAGS.BEAM_STOPPER):
					length = Beam.MAX_LENGTH;
			end = potential_end;
			length += 1;
		n_beams[direction.num] = Beam.new(from, end, direction, type, self);
	return n_beams;


func render_beam(beam: Beam) -> void:
	add_child(beam);


func add_emitter(emitter: LevelObject) -> void:
	beams[emitter] = {};


func get_emitters() -> Array:
	return beams.keys();


func generate_beams() -> void:
	for emitter in beams.keys() as Array[LevelObject]:
		var _beams = calculate_beams(emitter, get_coords_of_an_object(emitter));
		beams[emitter] = _beams;
		for beam in _beams.values():
			render_beam(beam);


func beam_on() -> void:
	for sensor in beam_sensitive.keys() as Array[LevelObject]:
		var coords = get_coords_of_an_object(sensor);
		for beams_per_emitter in beams.values():
			if beams_per_emitter == null:
				continue;
			for beam in beams_per_emitter.values() as Array[Beam]:
				if beam.are_coords_lit(coords):
					sensor._got_beamed_on(beam);


func update_beams() -> void:
	for emitter in get_emitters():
		var emitter_coords = get_coords_of_an_object(emitter);
		var _beams : Dictionary = beams[emitter];
		var new_beams := calculate_beams(emitter, emitter_coords);
		var merged := {};
		merged.merge(_beams);
		merged.merge(new_beams);
		for beam_direction in merged.keys():
			# compare calculated beams for each relevant direction
			match [_beams.get(beam_direction, null), new_beams.get(beam_direction, null)]:
				[null, null]:
					continue;
				# new beam appeared
				[null, var new_beam]:
					beams[emitter][beam_direction] = new_beam;
					render_beam(new_beam);
				# beam dissapeared
				[var beam, null]:
					beams[emitter].erase(beam_direction);
					remove_child(beam);
					beam.queue_free();
				# beam existed in this direction
				[var beam, var new_beam]:
					if beam.start != new_beam.start || beam.end != new_beam.end:
						update_beam(beam, new_beam);


func update_beam(beam: Beam, new_beam: Beam) -> void:
	beam.slide(new_beam.start, new_beam.end);


func tick_light() -> bool:
	var beam_update_required := false;
	for sensor in beam_sensitive.keys() as Array[LevelObject]:
		if sensor._light_tick():
			beam_update_required = true;
	return beam_update_required;
#endregion


#region reactions processing
var transients := {};

func tick_turn() -> void:
	for transient in transients.keys() as Array[LevelObject]:
		transient._turn_tick();
#endregion


# meta 
@export var level_name := "test level";
var _main_ref : MainScene = null;
@export var next_level_id : MainScene.LevelID = MainScene.LevelID.INTRODUCTION;
var level_objects : Array[Node] = [];


const SCREEN_SIZE := Vector2(1280., 720.);
const DEFAULT_LEVEL_SIZE := Vector2i(15, 9);
@export var level_size := Vector2i(15, 9);
@export var ravine_x : int = 8;
@export var left_door_location := Vector2i(1, 0);
@export var right_door_location := Vector2i(9, 0);
@export var left_door_upside_down_location := Vector2i(-1, -1);
@export var right_door_upside_down_location := Vector2i(-1, -1);


func go_next() -> void:
	if _main_ref != null:
		_main_ref.load_level(next_level_id);


# display
var camera_offset : Vector2i;
func _cycle_character() -> void:
	match selected_character:
			CHARACTER_ID.ARYA:
				selected_character = CHARACTER_ID.ALTA;
			CHARACTER_ID.ALTA:
				selected_character = CHARACTER_ID.ARYA;


func spawn_ravine() -> void:
	if ravine_x == -1 || level_size == Vector2i(-1, -1):
		return;
	
	for y in range(-1, level_size.y + 1):
		if y == 0:
			continue;
		var t_hole = PitObject.new();
		t_hole.starting_coords = Vector2i(ravine_x, y)
		t_hole.variant = PitObject.ABYSS;
		if y == -1:
			t_hole._direction = Direction.DOWN;
			t_hole.add_tag(LevelObject.TAGS.BEAM_EMITTER);
			t_hole.emitter_type = Beam.TYPE.LIGHT;
		if y == 1:
			t_hole.variant = PitObject.MIDDLE_TOP;
		if y == level_size.y:
			t_hole.variant = PitObject.MIDDLE_BOTTOM;
		add_child(t_hole);


func spawn_exits() -> void:
	if left_door_location != Vector2i(-1, -1):
		spawn_exit(left_door_location, true);
	if right_door_location != Vector2i(-1, -1):
		spawn_exit(right_door_location, false);


func spawn_exit(at: Vector2i, is_dark: bool) -> void:
	var t_door := WallObject.new();
	t_door.starting_coords = at;
	var t_door_ud := WallObject.new();
	t_door_ud.starting_coords = Vector2i(at.x, 10);
	
	if is_dark:
		t_door.variant = WallObject.DARK_DOOR;
		
		t_door_ud.variant = WallObject.DARK_DOOR_UPSIDE_DOWN;
		if left_door_upside_down_location != Vector2i(-1, -1):
			t_door_ud.starting_coords = left_door_upside_down_location;
	else:
		t_door.variant = WallObject.LIGHT_DOOR;
		
		t_door_ud.variant = WallObject.LIGHT_DOOR_UPSIDE_DOWN;
		if right_door_upside_down_location != Vector2i(-1, -1):
			t_door_ud.starting_coords = right_door_upside_down_location;
	
	var t_win_tile := ExitObject.new();
	var bottom = level_size.x + 2;
	var farright = level_size.y + 2;
	match [at.x, at.y]:
		[0, 0]:
			return; #xd
		[0, _]:
			t_door._direction = Direction.RIGHT;
		[_, 0]:
			t_door._direction = Direction.DOWN;
		[bottom, _]:
			t_door._direction = Direction.UP;
		[farright, _]:
			t_door._direction = Direction.LEFT;
		[_, _]:
			return; #xd
	t_win_tile.starting_coords = at + t_door.direction.vec;
	t_win_tile.direction = t_door.direction.reversed();
	
	add_child(t_door);
	add_child(t_door_ud);
	add_child(t_win_tile);


func spawn_walls() -> void:
	if level_size == Vector2i(-1, -1):
		return;
	
	var t_background = Sprite2D.new();
	t_background.texture = preload("res://assets/terrain/background.png");
	t_background.centered = false;
	t_background.offset = -self.position;
	t_background.z_index = -3;
	add_child(t_background);
	
	for x in (level_size.x + 2):
		if x == ravine_x:
			continue;
		for y in (level_size.y + 2):
			if Vector2i(x, y) == left_door_location || Vector2i(x, y) == right_door_location:
				continue;
			if x == 0 || y == 0 || x == level_size.x + 1 || y == level_size.y + 1:
				var t_wall = WallObject.new(true);
				t_wall.starting_coords = Vector2i(x, y);
				add_child(t_wall);


func adjust_offset() -> void:
	var field_size : Vector2 = Vector2(level_size + Vector2i(2, 2)) * cell_size;
	var offset = (SCREEN_SIZE - field_size) / 2.;
	position = offset;


var ran_once : bool = false;
func _ready() -> void:
	if !ran_once:
		adjust_offset();
		spawn_ravine();
		spawn_exits();
		spawn_walls();
		y_sort_enabled = true;
		ran_once = true;
	
	if Engine.is_editor_hint() && get_tree() != null:
		var timer = get_tree().create_timer(1.);
		timer.timeout.connect(_ready);
		for beam in get_children().filter(func(ch: Node): return ch as Beam != null):
			remove_child(beam);
			(beam as Node).free();
		_objects_that_matter.clear();
		beams.clear();
		beam_sensitive.clear();
		transients.clear();
	
	if !Engine.is_editor_hint() && get_tree() != null:
		_main_ref = get_tree().root.get_node("Main") as MainScene;
	
	level_objects = get_children().filter(func(ch : Node): return ch as LevelObject != null);
	for obj in level_objects:
		obj.place_on_level(coords2position(obj.starting_coords), self);
		if !obj.has_tag(LevelObject.TAGS.DECORATION):
			add_object(obj.starting_coords, obj);
		if obj.has_tag(LevelObject.TAGS.BEAM_EMITTER):
			add_emitter(obj);
		if obj.has_tag(LevelObject.TAGS.BEAM_SENSITIVE):
			beam_sensitive[obj] = null;
		if obj.has_tag(LevelObject.TAGS.TRANSIENT):
			transients[obj] = null;
	
	generate_beams();
	process_lights();
	tick_turn();
	process_lights();
	tick_turn(); # this is required for solar panels to power stuff at the start of a level
	process_lights();


func _cancel() -> void:
	if turn_number > 0:
		turn_number -= 1;
		load_state();
		process_lights();


enum {
	CHANGE,
	MOVE_UP, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT,
	UNDO,
}
var delay : Array[Array] = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]; # :)
const ACTION_DELAY : int = 200;
const ACTION_RESET : int = 300;


func check_delay(action: int) -> bool:
	if Time.get_ticks_msec() - delay[action][0] > ACTION_RESET:
		delay[action][1] = 0;
	return Time.get_ticks_msec() - delay[action][0] > ACTION_DELAY;


func update_delay(action: int) -> void:
	delay[action][0] = Time.get_ticks_msec();
	delay[action][1] += 1;


func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): # dont run in the editor
		return;
	
	if _main_ref != null && _main_ref.paused:
		return;
	
	if Input.is_action_just_pressed("change_character"): #0
		_cycle_character();
	
	if Input.is_action_pressed("move_down"): #1
		if Input.is_action_just_pressed("move_down") || check_delay(MOVE_DOWN):
			move_character(Direction.DOWN);
			update_delay(MOVE_DOWN);
	
	if Input.is_action_pressed("move_up"): #2
		if Input.is_action_just_pressed("move_up") || check_delay(MOVE_UP):
			move_character(Direction.UP);
			update_delay(MOVE_UP);
	
	if Input.is_action_pressed("move_left"): #3
		if Input.is_action_just_pressed("move_left") || check_delay(MOVE_LEFT):
			move_character(Direction.LEFT);
			update_delay(MOVE_LEFT);
	
	if Input.is_action_pressed("move_right"): #4
		if Input.is_action_just_pressed("move_right") || check_delay(MOVE_RIGHT):
			move_character(Direction.RIGHT);
			update_delay(MOVE_RIGHT);
	
	if Input.is_action_pressed("undo"):
		if Input.is_action_just_pressed("undo") || check_delay(UNDO):
			_cancel();
			update_delay(UNDO);
