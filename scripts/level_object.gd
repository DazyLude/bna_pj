@tool
@icon("res://assets/icons/box_icon.svg")
extends Node2D
class_name LevelObject


enum TAGS {
	DECORATION, #0
	ALTA, #1
	ARYA, #2
	PUSH, #3
	STOP, #4
	LIGHT, #5
	HEAVY, #6
	BEAM_SENSITIVE, #7
	BEAM_STOPPER, #8
	BEAM_EMITTER, #9
	TRANSIENT, #10
	FLYING, #11
	WIN, #12
}


var direction := Direction.new()
@export_enum("UP", "DOWN", "LEFT", "RIGHT") var _direction : int :
	get:
		return direction.num;
	set(new_v):
		direction.num = new_v;

func _get_emission_directions() -> Array :
	return [direction];

@export var emitter_type : Beam.TYPE = Beam.TYPE.NONE;
func _get_emission_type(direction: int) -> Beam.TYPE:
	return emitter_type;


@export var starting_coords := Vector2i(0, 0);
# can be rewritten as a bitmask for performance boost, but I don't know how to export it to the editor
# exporting could be done by setting an array, as it is already done,
# but using setters and getters; we can generate array by working with an actual stored bitmask.
# 
# However, a bitmask has to be implemented first :)
# or just write a GDExtention kekw 
# can be rewritten as a bitmap, it is supported by the GDScript
@export var tags : Array[TAGS] = [];
var stuck : bool = false;
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
var _level_ref : GameLevel = null;


func place_on_level(starting_position: Vector2, level: GameLevel) -> void:
	position = starting_position;
	
	_starting_position = starting_position;
	_desired_position = starting_position;
	_level_ref = level;
	
	_prepare_visuals();


func _prepare_visuals() -> void:
	var diff =  _level_ref.cell_size - _sprite.get_rect().size;
	_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);


func change_direction(new_direction: Direction) -> void:
	_direction = new_direction.num;


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
	#overload this to do custom movement animations for an object
	if _movement_mode != _STOP:
		if _movement_progress < 1.:
			_movement_progress = minf(_movement_progress + delta * _movement_speed_multiplier, 1.);
			match _movement_mode:
				_MOVE:
					position = _starting_position.lerp(_desired_position, smoothstep(0., 1., _movement_progress));
				_NUDGE:
					position = _starting_position.lerp(_desired_position, sin(_movement_progress * PI) / 10.);
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


var beamed_on_by : Dictionary = {};


func _got_beamed_on(beam: Beam) -> void:
	# overload this to add light interactivity
	beamed_on_by[beam] = null;


func _light_tick() -> bool:
	# overload this to add light interactivity
	beamed_on_by.clear();
	return false;


func _turn_tick():
	# overload this to add time interactivity
	pass;
