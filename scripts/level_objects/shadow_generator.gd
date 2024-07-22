@tool
extends LevelObject
class_name ShadowGenerator


var shadowing : Dictionary = {};

func _get_emission_directions() -> Array:
	var result := []
	for dir_num in shadowing.keys():
		result.push_back(Direction.from_num(dir_num));
	return result;


func _init() -> void:
	tags.push_back(TAGS.BEAM_SENSITIVE);
	tags.push_back(TAGS.BEAM_EMITTER);
	tags.push_back(TAGS.BEAM_STOPPER);
	tags.push_back(TAGS.PUSH);
	emitter_type = Beam.TYPE.NONE;


func _light_tick() -> bool:
	shadowing.clear();
	
	for beam in beamed_on_by.keys() as Array[Beam]:
		if beam.btype == beam.TYPE.LIGHT:
			shadowing[beam.direction.num] = null;
	
	if shadowing.has(Direction.UP) && shadowing.has(Direction.DOWN):
		shadowing.erase(Direction.UP);
		shadowing.erase(Direction.DOWN);
	
	if shadowing.has(Direction.LEFT) && shadowing.has(Direction.RIGHT):
		shadowing.erase(Direction.LEFT);
		shadowing.erase(Direction.RIGHT);
	
	var changes = false;
	
	if shadowing.size() != 0:
		changes = emitter_type != Beam.TYPE.SHADOW;
		emitter_type = Beam.TYPE.SHADOW;
	else:
		changes = emitter_type != Beam.TYPE.NONE;
		emitter_type = Beam.TYPE.NONE;
	
	super._light_tick();
	return changes;
