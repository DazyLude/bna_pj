@tool
extends Node2D
class_name Beam


const MAX_LENGTH = 40;


enum TYPE {
	NONE,
	LIGHT,
	SHADOW,
}
var atlas := AtlasTexture.new();


func _get_beam_color(type : TYPE) -> Color:
	match type:
		TYPE.LIGHT:
			return Color(227./255., 227./255., 93./255., 0.3);
		TYPE.SHADOW:
			return Color(30./255., 30./255., 40./255., 0.4);
		_:
			return Color(0., 0., 0., 0.,);


func _get_beam_sprite() -> Resource:
	match direction.num:
		Direction.UP, Direction.DOWN:
			atlas.region.position = Vector2(64., 0.);
		_:
			atlas.region.position = Vector2(0., 0.);
	return atlas;



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
		match direction.num:
			Direction.UP, Direction.DOWN:
				return (_end - _start).abs() + Vector2(_level_ref.cell_size.x, 0.);
			_:
				return (_end - _start).abs() + Vector2(0., _level_ref.cell_size.y);


var _beam_position : Vector2:
	get:
		match direction.num:
			Direction.UP:
				return _end - _start + Vector2(0., _level_ref.cell_size.y / 2);
			Direction.LEFT:
				return _end - _start + Vector2(_level_ref.cell_size.x / 2, 0.);
			Direction.DOWN:
				return Vector2(0., _level_ref.cell_size.y / 2);
			Direction.RIGHT, _:
				return Vector2(_level_ref.cell_size.x / 2, 0.);


var _desired_beam_size : Vector2:
	get:
		match direction.num:
			Direction.UP, Direction.DOWN:
				return (_desired_end - _desired_start).abs() + Vector2(_level_ref.cell_size.x, 0.);
			_:
				return (_desired_end - _desired_start).abs() + Vector2(0., _level_ref.cell_size.y);


var _desired_beam_position : Vector2:
	get:
		match direction.num:
			Direction.UP:
				return _desired_end - _desired_start + Vector2(0., _level_ref.cell_size.y / 2);
			Direction.LEFT:
				return _desired_end - _desired_start + Vector2(_level_ref.cell_size.x / 2, 0.);
			Direction.DOWN:
				return Vector2(0., _level_ref.cell_size.y / 2);
			Direction.RIGHT, _:
				return Vector2(_level_ref.cell_size.x / 2, 0.);


var start := Vector2i(0, 0);
var end := Vector2i(0, 0);
var direction : Direction = null;
var btype : TYPE;


var _level_ref : GameLevel = null;
var _beam_body_ref : Node = null;


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
	self.direction = Direction.from_num(dir.num);
	self.btype = type;
	
	_level_ref = level;
	_start = level.coords2position(from);
	_end = level.coords2position(to);
	
	match btype:
		TYPE.LIGHT:
			atlas.atlas = preload("res://assets/objects/light_trans_sh.png");
			z_index = 1;
		TYPE.SHADOW:
			atlas.atlas = preload("res://assets/objects/dark_trans_sh.png");
			z_index = 1;
	atlas.region.size = Vector2(64., 64.);


func _ready() -> void:
	var beam_body = null;
	beam_body = Sprite2D.new();
	beam_body.centered = false;
	beam_body.texture = _get_beam_sprite();
	
	_beam_body_ref = beam_body;
	add_child(beam_body);
	
	position = _start;
	beam_body.position = _beam_position;
	beam_body.scale = _beam_size / Vector2(64., 64.);


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
					_beam_body_ref.scale = _beam_size.lerp(_desired_beam_size, smoothstep(0.49, 0.51, _movement_progress)) / Vector2(64., 64.) ;
		else:
			_movement_mode = _STOP;
