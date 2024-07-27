@tool
extends Node2D
class_name Beam


const MAX_LENGTH = 40;


enum TYPE {
	NONE,
	LIGHT,
	SHADOW,
}


func _get_beam_color(type : TYPE) -> Color:
	match type:
		TYPE.LIGHT:
			return Color(227./255., 227./255., 93./255., 0.3);
		TYPE.SHADOW:
			return Color(30./255., 30./255., 40./255., 0.4);
		_:
			return Color(0., 0., 0., 0.,);


enum {
	_STOP,
	_SLIDE,
}


const _movement_speed_multiplier : float = 10.; # 1/ms
var _movement_progress : float = 1.;
var _movement_mode = _STOP; 

var _start := Vector2(0., 0.);
var _desired_start := Vector2(0., 0.);
var _end := Vector2(0., 0.);
var _desired_end := Vector2(0., 0.);

var _beam_size : Vector2:
	get:
		return (_end - _start).abs() + _level_ref.cell_size;

var _beam_position : Vector2:
	get:
		match direction.num:
			Direction.UP, Direction.LEFT:
				return _end - _start;
			_:
				return Vector2(0., 0.);

var _desired_beam_size : Vector2:
	get:
		return (_desired_end - _desired_start).abs() + _level_ref.cell_size;

var _desired_beam_position : Vector2:
	get:
		match direction.num:
			Direction.UP, Direction.LEFT:
				return _desired_end - _desired_start;
			_:
				return Vector2(0., 0.);


var start := Vector2i(0, 0);
var end := Vector2i(0, 0);
var direction : Direction = null;
var btype : TYPE;


var _level_ref : GameLevel = null;
var _beam_body_ref : ColorRect = null;


func are_coords_lit(coords: Vector2i) -> bool:
	match direction.num:
		Direction.UP when start.x == coords.x:
			return start.y > coords.y && coords.y >= end.y;
		Direction.DOWN when start.x == coords.x:
			return start.y < coords.y && coords.y <= end.y;
		Direction.LEFT when start.y == coords.y:
			return start.x > coords.x && coords.x >= end.x;
		Direction.RIGHT when start.y == coords.y:
			return start.x < coords.x && coords.x <= end.x;
		_:
			return false;


func _init(from: Vector2i, to: Vector2i, dir: Direction, type: TYPE, level: GameLevel) -> void:
	start = from;
	end = to;
	self.direction = dir;
	self.btype = type;
	
	_level_ref = level;
	_start = level.coords2position(from);
	_end = level.coords2position(to);


func _ready() -> void:
	var beam_body := ColorRect.new();
	beam_body.color = _get_beam_color(btype);
	_beam_body_ref = beam_body;
	add_child(beam_body);
	position = _start;
	beam_body.position = _beam_position;
	beam_body.size = _beam_size;


func slide(new_start: Vector2, new_end: Vector2) -> void:
	
	_setup_movement(new_start, new_end);
	_movement_mode = _SLIDE;


func _setup_movement(new_start: Vector2, new_end: Vector2) -> void:
	_start = _level_ref.coords2position(start);
	_end = _level_ref.coords2position(end);
	start = new_start;
	end = new_end;
	_desired_start = _level_ref.coords2position(new_start);
	_desired_end = _level_ref.coords2position(new_end);
	_movement_progress = 0.;


func _process(delta: float) -> void:
	if _movement_mode != _STOP:
		if _movement_progress < 1.:
			_movement_progress = minf(_movement_progress + delta * _movement_speed_multiplier, 1.);
			match _movement_mode:
				_SLIDE:
					position = _start.lerp(_desired_start, smoothstep(0.49, 0.51, _movement_progress));
					_beam_body_ref.position = _beam_position.lerp(_desired_beam_position, smoothstep(0.49, 0.51, _movement_progress));
					_beam_body_ref.size = _beam_size.lerp(_desired_beam_size, smoothstep(0.49, 0.51, _movement_progress));
		else:
			_movement_mode = _STOP;
