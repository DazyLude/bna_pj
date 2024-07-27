@tool
extends LevelObject
class_name SolarPower


var active = false;
func is_powered() -> bool:
	return active;


func _ready() -> void:
	tags.push_back(TAGS.BEAM_SENSITIVE);
	tags.push_back(TAGS.BEAM_STOPPER);
	tags.push_back(TAGS.PUSH);
	super._ready();


func _prepare_visuals() -> void:
	_sprite.texture = preload("res://assets/solar.png");


func _light_tick() -> bool:
	var t_active = false;
	for beam in beamed_on_by.keys() as Array[Beam]:
		if beam.btype == Beam.TYPE.LIGHT:
			t_active = true;
	
	var check = t_active != active;
	active = t_active;
	
	super._light_tick();
	return check;
