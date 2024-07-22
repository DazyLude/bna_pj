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
	var temp_reflecting := {};
	for beam in beamed_on_by.keys() as Array[Beam]:
		if beam.btype != Beam.TYPE.LIGHT:
			continue;
		
		if beam.direction.reversed().num == vertical_direction:
			temp_reflecting[horizontal_direction] = null;
		elif beam.direction.reversed().num == horizontal_direction:
			temp_reflecting[vertical_direction] = null;
	
	var changes = temp_reflecting != reflecting;
	reflecting = temp_reflecting;
	
	if reflecting.size() != 0:
		emitter_type = Beam.TYPE.LIGHT;
	else:
		emitter_type = Beam.TYPE.NONE;
	
	super._light_tick();
	return changes;


func change_direction(new_direction: Direction) -> void:
	match new_direction.num:
		Direction.UP, Direction.DOWN:
			vertical_direction = new_direction.num;
		Direction.LEFT, Direction.RIGHT:
			horizontal_direction = new_direction.num;
	super.change_direction(new_direction);
