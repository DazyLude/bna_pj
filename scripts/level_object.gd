@icon("res://assets/box_icon.svg")
extends Node2D
class_name LevelObject


@export var starting_coords := Vector2i(0, 0);
@export var tags : Dictionary = {};
@export var custom_sprite : Texture2D = null;
@export var margin_from_bottom : float = 10.;
var _sprite : Sprite2D = null;


const _movement_speed_multiplier : float = 100.; # 1/ms
var _starting_position : Vector2;
var _desired_position : Vector2;
var _movement_progress : float = 1.;


func place_on_level(starting_position: Vector2, level: GameLevel) -> void:
	position = starting_position;
	_starting_position = starting_position;
	_desired_position = starting_position;
	var diff =  level.cell_size - _sprite.get_rect().size;
	_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);



func move_to(new_position: Vector2) -> void:
	_starting_position = position;
	_desired_position = new_position;
	
	_movement_progress = 0.;


func _process(delta: float) -> void:
	if _movement_progress < 1.:
		_movement_progress = minf(_movement_progress + delta * _movement_speed_multiplier, 1.);
		position = _starting_position.slerp(_desired_position, _movement_progress);


func _ready() -> void:
	var sprite := Sprite2D.new();
	if custom_sprite != null:
		sprite.texture = custom_sprite;
	else:
		sprite.texture = load("res://assets/7070ph.png");
	sprite.centered = false;
	_sprite = sprite;
	add_child(_sprite);
