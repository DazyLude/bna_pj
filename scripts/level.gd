#@icon("res://assets/level_icon.svg")
extends Node2D
class_name GameLevel


enum CHARACTER_ID {
	ALTA,
	ARYA,
}

# coordinate system
const origin := Vector2(0., 0.);
const cell_size := Vector2(70., 70.);


func coords2position(coords: Vector2i) -> Vector2:
	return cell_size * Vector2(coords) + origin;


# character system
signal changed_selected_character(CHARACTER_ID);
var selected_character : CHARACTER_ID = CHARACTER_ID.ARYA:
	set(new_value):
		changed_selected_character.emit(new_value);
		selected_character = new_value;
	get:
		return selected_character;


#region level data
@export var level_objects : Array[LevelObject] = [];
var _level_terrain := TileMap.new(); 
var _level_terrain_set : TileSet = preload("res://assets/terrain.tres");
# { coords: [object in this cell, object in this cell... ] }
var _objects_that_matter : Dictionary = {};


func get_objects_by_tag(tag: String) -> Array[LevelObject]:
	var result : Array[LevelObject] = [];
	for coords in _objects_that_matter.keys():
		for obj in _objects_that_matter[coords]:
			if (obj as LevelObject).tags.has("tag"):
				result.push_back(obj);
	return result;


func get_objects_by_coords(coords: Vector2i) -> Array[LevelObject]:
	return _objects_that_matter.get(coords, []);


func get_coords_of_an_object(object: LevelObject) -> Vector2i:
	for coords in _objects_that_matter.keys():
		for obj in _objects_that_matter[coords]:
			if obj == object:
				return coords;
	print_debug("object %s not found" % object);
	return Vector2i(0, 0);


func add_level_object(coords: Vector2i, object: LevelObject) -> void:
	pass;


func remove_level_object(object: LevelObject, coords: Vector2i) -> void:
	pass;
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
	for obj in level_objects:
		obj.place_on_level(coords2position(obj.starting_coords), self);


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("change_character"):
		_cycle_character();


