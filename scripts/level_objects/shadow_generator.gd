@tool
extends LevelObject
class_name ShadowGenerator


var shadowing : Dictionary = {};
@export_enum("box", "screen") var variant : int = 0;

func _get_emission_directions() -> Array:
	var result := []
	for dir_num in shadowing.keys():
		result.push_back(Direction.from_num(dir_num));
	return result;


func _ready() -> void:
	super._ready();
	match variant:
		0:
			_sprite.texture = load("res://assets/box.png");
		1:
			_sprite.texture = load("res://assets/screen.png");


func _init() -> void:
	tags.push_back(TAGS.BEAM_SENSITIVE);
	tags.push_back(TAGS.BEAM_EMITTER);
	tags.push_back(TAGS.BEAM_STOPPER);
	tags.push_back(TAGS.PUSH);
	emitter_type = Beam.TYPE.NONE;


func _light_tick() -> bool:
	var temp_shadowing := {};
	for beam in beamed_on_by.keys() as Array[Beam]:
		if beam.btype == beam.TYPE.LIGHT:
			temp_shadowing[beam.direction.num] = null;
	
	if temp_shadowing.has(Direction.UP) && temp_shadowing.has(Direction.DOWN):
		temp_shadowing.erase(Direction.UP);
		temp_shadowing.erase(Direction.DOWN);
	
	if temp_shadowing.has(Direction.LEFT) && temp_shadowing.has(Direction.RIGHT):
		temp_shadowing.erase(Direction.LEFT);
		temp_shadowing.erase(Direction.RIGHT);
	
	var changes = temp_shadowing != shadowing;
	shadowing = temp_shadowing;
	
	match shadowing.size():
		0:
			emitter_type = Beam.TYPE.NONE;
		_:
			emitter_type = Beam.TYPE.SHADOW;
	
	super._light_tick();
	return changes;
