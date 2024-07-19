#@icon("res://assets/level_icon.svg")
extends Node2D
class_name GameLevel


enum CHARACTER_ID {
	ALTA,
	ARYA,
}

enum _DIRECTION {
	UP, DOWN, LEFT, RIGHT
}


# coordinate system
const origin := Vector2(0., 0.);
const cell_size := Vector2(64., 64.);


func coords2position(coords: Vector2i) -> Vector2:
	return cell_size * Vector2(coords) + origin;


#region level data
@export var level_objects : Array[LevelObject] = [];
var _level_terrain := TileMap.new(); 
var _level_terrain_set : TileSet = preload("res://assets/terrain.tres");
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


func move_character(direction: _DIRECTION) -> void:
	match selected_character:
		CHARACTER_ID.ARYA:
			for arya in get_objects_by_tag(LevelObject.TAGS.ARYA):
				try_move(arya, direction);
		CHARACTER_ID.ALTA:
			for arya in get_objects_by_tag(LevelObject.TAGS.ALTA):
				try_move(arya, direction);
#endregion


#region movement processing
class MoveDTO extends RefCounted:
	var object : LevelObject = null;
	var from := Vector2i(0, 0);
	var to := Vector2i(0, 0);
	
	
	func _init(object: LevelObject, from: Vector2i, to: Vector2i) -> void:
		self.object = object;
		self.from = from;
		self.to = to;


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
	
	
	func dont() -> MovementData:
		objects_moved.clear();
		is_executable = false;
		return self;
	
	
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


func try_move(object: LevelObject, direction: _DIRECTION):
	var from := get_coords_of_an_object(object);
	var delta : Vector2i;
	match direction:
		_DIRECTION.UP:
			delta = Vector2i(0, -1);
		_DIRECTION.DOWN:
			delta = Vector2i(0, 1);
		_DIRECTION.LEFT:
			delta = Vector2i(-1, 0);
		_DIRECTION.RIGHT:
			delta = Vector2i(1, 0);
	var to = from + delta;
	
	var move := check_move(object, from, to);
	if move.is_executable:
		execute_move(move);
	else:
		object.nudge(coords2position(to));
#endregion


# meta 
@export var level_name := "test level";
@onready var _main_ref : MainScene = get_tree().root.get_node("Main") as MainScene;


# display
var camera_offset : Vector2i;


func _cycle_character() -> void:
	match selected_character:
			CHARACTER_ID.ARYA:
				selected_character = CHARACTER_ID.ALTA;
			CHARACTER_ID.ALTA:
				selected_character = CHARACTER_ID.ARYA;


func _ready() -> void:
	y_sort_enabled = true;
	for obj in level_objects:
		obj.place_on_level(coords2position(obj.starting_coords), self);
		if !obj.has_tag(LevelObject.TAGS.DECORATION):
			add_object(obj.starting_coords, obj);


func _process(_delta: float) -> void:
	if _main_ref.paused:
		return;
	
	if Input.is_action_just_pressed("change_character"):
		_cycle_character();
	if Input.is_action_just_pressed("move_down"):
		move_character(_DIRECTION.DOWN);
	if Input.is_action_just_pressed("move_up"):
		move_character(_DIRECTION.UP);
	if Input.is_action_just_pressed("move_left"):
		move_character(_DIRECTION.LEFT);
	if Input.is_action_just_pressed("move_right"):
		move_character(_DIRECTION.RIGHT);


