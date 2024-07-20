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

var start := Vector2i(0, 0);
var end := Vector2i(0, 0);
var _level_ref : GameLevel = null;
var _emitter_ref : LevelObject = null;


func _init(from: Vector2i, to: Vector2i, emitter: LevelObject, level: GameLevel) -> void:
	start = from;
	end = to;
	_emitter_ref = emitter
	_level_ref = level;
	_start = level.coords2position(from);
	_end = level.coords2position(to);
	#_expand(_start, level.coords2position(to))


func _ready() -> void:
	position = _start;
	
	var beam_body := ColorRect.new();
	beam_body.size = _end - _start + _level_ref.cell_size;
	beam_body.color = _get_beam_color(_emitter_ref.emitter_type);
	add_child(beam_body)


func _expand(new_start: Vector2, new_end: Vector2) -> void:
	_desired_start = new_start;
	_desired_end = new_end;
	_movement_mode = _EXPAND;
	_movement_progress = 0.;


func _process(delta: float) -> void:
	pass;
