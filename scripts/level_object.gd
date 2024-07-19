@icon("res://assets/box_icon.svg")
extends Node2D
class_name LevelObject


enum TAGS {
	DECORATION,
	ALTA,
	ARYA,
	PUSH,
	STOP,
}


@export var starting_coords := Vector2i(0, 0);
@export var tags : Array[TAGS] = [];
@export var custom_sprite : Texture2D = null;
@export var margin_from_bottom : float = 10.;
var _sprite : Sprite2D = null;


#region amongus cock
#⣿⣿⣿⠟⢹⣶⣶⣝⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
#⣿⣿⡟⢰⡌⠿⢿⣿⡾⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
#⣿⣿⣿⢸⣿⣤⣒⣶⣾⣳⡻⣿⣿⣿⣿⡿⢛⣯⣭⣭⣭⣽⣻⣿⣿⣿
#⣿⣿⣿⢸⣿⣿⣿⣿⢿⡇⣶⡽⣿⠟⣡⣶⣾⣯⣭⣽⣟⡻⣿⣷⡽⣿
#⣿⣿⣿⠸⣿⣿⣿⣿⢇⠃⣟⣷⠃⢸⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽
#⣿⣿⣿⣇⢻⣿⣿⣯⣕⠧⢿⢿⣇⢯⣝⣒⣛⣯⣭⣛⣛⣣⣿⣿⣿⡇
#⣿⣿⣿⣿⣌⢿⣿⣿⣿⣿⡘⣞⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
#⣿⣿⣿⣿⣿⣦⠻⠿⣿⣿⣷⠈⢞⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
#⣿⣿⣿⣿⣿⣿⣗⠄⢿⣿⣿⡆⡈⣽⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻
#⣿⣿⣿⣿⡿⣻⣽⣿⣆⠹⣿⡇⠁⣿⡼⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣾
#⣿⠿⣛⣽⣾⣿⣿⠿⠋⠄⢻⣷⣾⣿⣧⠟⣡⣾⣿⣿⣿⣿⣿⣿⡇⣿
#⢼⡟⢿⣿⡿⠋⠁⣀⡀⠄⠘⠊⣨⣽⠁⠰⣿⣿⣿⣿⣿⣿⣿⡍⠗⣿
#⡼⣿⠄⠄⠄⠄⣼⣿⡗⢠⣶⣿⣿⡇⠄⠄⣿⣿⣿⣿⣿⣿⣿⣇⢠⣿
#⣷⣝⠄⠄⢀⠄⢻⡟⠄⣿⣿⣿⣿⠃⠄⠄⢹⣿⣿⣿⣿⣿⣿⣿⢹⣿
#⣿⣿⣿⣿⣿⣧⣄⣁⡀⠙⢿⡿⠋⠄⣸⡆⠄⠻⣿⡿⠟⢛⣩⣝⣚⣿
#⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⣤⣤⣾⣿⣿⣄⠄⠄⠄⣴⣿⣿⣿⣇⣿
#⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⡀⠛⠿⣿⣫⣾⣿ 
#endregion

enum {
	_STOP,
	_MOVE,
	_NUDGE,
}


const _movement_speed_multiplier : float = 10.; # 1/ms
var _starting_position : Vector2;
var _desired_position : Vector2;
var _movement_progress : float = 1.;
var _movement_mode = _STOP; 


func place_on_level(starting_position: Vector2, level: GameLevel) -> void:
	position = starting_position;
	_starting_position = starting_position;
	_desired_position = starting_position;
	var diff =  level.cell_size - _sprite.get_rect().size;
	_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);


func move_to(new_position: Vector2) -> void:
	_movement_mode = _MOVE;
	_starting_position = position;
	_desired_position = new_position;
	
	_movement_progress = 0.;


func nudge(to: Vector2) -> void:
	_movement_mode = _NUDGE;
	_starting_position = position;
	_desired_position = to;
	
	_movement_progress = 0.;


func has_tag(tag: TAGS) -> bool:
	return tags.has(tag);


func _process(delta: float) -> void:
	if _movement_mode != _STOP:
		if _movement_progress < 1.:
			_movement_progress = minf(_movement_progress + delta * _movement_speed_multiplier, 1.);
			match _movement_mode:
				_MOVE:
					position = _starting_position.lerp(_desired_position, smoothstep(0., 1., _movement_progress));
				_NUDGE:
					position = _starting_position.lerp(_desired_position, sin(_movement_progress * PI));
		else:
			_movement_mode = _STOP;


func _ready() -> void:
	var sprite := Sprite2D.new();
	if custom_sprite != null:
		sprite.texture = custom_sprite;
	else:
		sprite.texture = load("res://assets/7070ph.png");
	sprite.centered = false;
	_sprite = sprite;
	add_child(_sprite);
