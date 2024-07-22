@tool
@icon("res://assets/level_icon.svg")
extends Node2D
class_name GameLevel


enum CHARACTER_ID {
	ALTA,
	ARYA,
}


# coordinate system
const origin := Vector2(0., 0.);
const cell_size := Vector2(64., 64.);


func coords2position(coords: Vector2i) -> Vector2:
	return cell_size * Vector2(coords) + origin;


#region level data system
@export var level_terrain : TileMap = null; 
var _level_terrain_set : TileSet = preload("res://assets/terrain/terrain.tres");
# { coords: [object in this cell, object in this cell... ] }
var _objects_that_matter : Dictionary = {};


func get_objects_by_tag(tag: LevelObject.TAGS) -> Array:
	var result : Array[LevelObject] = [];
	for coords in _objects_that_matter.keys():
		for obj in _objects_that_matter[coords]:
			if (obj as LevelObject).has_tag(tag):
				result.push_back(obj);
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


func process_lights():
	update_beams();
	beam_on();
	var recursion_depth = 0;
	while recursion_depth < 10 && tick_light():
		update_beams();
		beam_on();
		recursion_depth += 1;
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
		if obj.has_tag(LevelObject.TAGS.STOP):
			# stop movement
			movement.is_executable = false;
			break;
		if obj.has_tag(LevelObject.TAGS.PUSH):
			# try to move object as well
			var obj_movement = check_move(obj, to, to * 2 - from);
			movement.add(obj_movement);
	
	# if the movement stack is too heavy, don't move at all
	if movement.weight > 1:
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
	if move.is_executable:
		execute_move(move);
	else:
		object.nudge(coords2position(to));
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


# display
var camera_offset : Vector2i;


func _cycle_character() -> void:
	match selected_character:
			CHARACTER_ID.ARYA:
				selected_character = CHARACTER_ID.ALTA;
			CHARACTER_ID.ALTA:
				selected_character = CHARACTER_ID.ARYA;


func _ready() -> void:
	if Engine.is_editor_hint():
		var timer = get_tree().create_timer(1.);
		timer.timeout.connect(_ready);
		for beam in get_children().filter(func(ch: Node): return ch as Beam != null):
			remove_child(beam);
			(beam as Node).free();
		_objects_that_matter.clear();
		beams.clear();
		beam_sensitive.clear();
		transients.clear();
	
	
	if !Engine.is_editor_hint():
		_main_ref = get_tree().root.get_node("Main") as MainScene;
	
	
	y_sort_enabled = true;
	var level_objects = get_children().filter(func(ch : Node): return ch as LevelObject != null);
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
	beam_on();
	tick_light();
	process_lights();
	


func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): # dont run in the editor
		return;
	
	if _main_ref.paused:
		return;
	
	if Input.is_action_just_pressed("change_character"):
		_cycle_character();
	if Input.is_action_just_pressed("move_down"):
		move_character(Direction.DOWN);
	if Input.is_action_just_pressed("move_up"):
		move_character(Direction.UP);
	if Input.is_action_just_pressed("move_left"):
		move_character(Direction.LEFT);
	if Input.is_action_just_pressed("move_right"):
		move_character(Direction.RIGHT);
