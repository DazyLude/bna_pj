@tool
extends LevelObject
class_name Prism


var reflecting : Dictionary = {};
var horizontal_direction : int = 2;
@export_enum("LEFT", "RIGHT") var _horizontal_direction : int :
	set(new_v):
		horizontal_direction = new_v + 2;
		_horizontal_direction = new_v;
var vertical_direction : int = 0;
@export_enum("UP", "DOWN") var _vertical_direction : int :
	set(new_v):
		horizontal_direction = new_v;
		_horizontal_direction = new_v;


func _get_emission_directions() -> Array:
	var result := []
	for dir_num in reflecting.keys():
		result.push_back(Direction.from_num(dir_num));
	return result;


func _init() -> void:
	tags.push_back(TAGS.BEAM_SENSITIVE);
	tags.push_back(TAGS.BEAM_EMITTER);
	tags.push_back(TAGS.BEAM_STOPPER);
	tags.push_back(TAGS.PUSH);
	emitter_type = Beam.TYPE.NONE;


func _light_tick() -> bool:
	reflecting.clear();
	for beam in beamed_on_by.keys() as Array[Beam]:
		match [beam.btype, beam.direction.num]:
			[var t, var d] when t == Beam.TYPE.LIGHT && d == vertical_direction:
				reflecting[horizontal_direction] = null;
			[var t, var d] when t == Beam.TYPE.LIGHT && d == horizontal_direction:
				reflecting[vertical_direction] = null;
	
	
	var changes = false;
	if reflecting.size() != 0:
		changes = emitter_type != Beam.TYPE.LIGHT;
		emitter_type = Beam.TYPE.LIGHT;
	else:
		changes = emitter_type != Beam.TYPE.NONE;
		emitter_type = Beam.TYPE.NONE;
	
	super._light_tick();
	return changes;


func change_direction(new_direction: Direction) -> void:
	match new_direction.num:
		Direction.UP:
			vertical_direction = Direction.UP;
		Direction.DOWN:
			vertical_direction = Direction.DOWN;
		Direction.LEFT:
			horizontal_direction = Direction.RIGHT;
		Direction.RIGHT:
			horizontal_direction = Direction.LEFT;
	super.change_direction(new_direction);
