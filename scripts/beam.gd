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
			return Color(227./255., 227./255., 93./255., 0.2);
		TYPE.SHADOW:
			return Color(40./255., 40./255., 60./255., 0.2);
		_:
			return Color(0., 0., 0., 0.,);


enum {
	_STOP,
	_EXPAND,
	_SLIDE,
}


const _movement_speed_multiplier : float = 10.; # 1/ms
var _movement_progress : float = 1.;
var _movement_mode = _STOP; 

var _start := Vector2(0., 0.);
var _desired_start := Vector2(0., 0.);
var _end := Vector2(0., 0.);
var _desired_end := Vector2(0., 0.);
var _beam_size:
	get:
		return _end - _start + _level_ref.cell_size;
var _desired_beam_size:
	get:
		return _desired_end - _desired_start + _level_ref.cell_size;

var start := Vector2i(0, 0);
var end := Vector2i(0, 0);
var _level_ref : GameLevel = null;
var _emitter_ref : LevelObject = null;
var _beam_body_ref : ColorRect = null;


func _init(from: Vector2i, to: Vector2i, emitter: LevelObject, level: GameLevel) -> void:
	start = from;
	end = to;
	_emitter_ref = emitter
	_level_ref = level;
	_start = level.coords2position(from);
	_end = level.coords2position(to);


func _ready() -> void:
	position = _start;
	var beam_body := ColorRect.new();
	_beam_body_ref = beam_body;
	beam_body.size = _end - _start + _level_ref.cell_size;
	beam_body.color = _get_beam_color(_emitter_ref.emitter_type);
	add_child(beam_body)


func expand(new_start: Vector2, new_end: Vector2) -> void:
	_setup_movement(new_start, new_end);
	_movement_mode = _EXPAND;


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
				_EXPAND:
					position = _start.lerp(_desired_start, smoothstep(0., 1., _movement_progress));
					_beam_body_ref.size = _beam_size.lerp(_desired_beam_size, smoothstep(0., 1., _movement_progress));
				_SLIDE:
					position = _start.lerp(_desired_start, smoothstep(0., 1., _movement_progress));
					_beam_body_ref.size = _beam_size.lerp(_desired_beam_size, smoothstep(0.49, 0.51, _movement_progress));
		else:
			_movement_mode = _STOP;
