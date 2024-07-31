@tool
extends LevelObject
class_name ShadowGenerator


var shadowing : Dictionary = {};
@export_enum("box", "screen", "light_box", "dark_box") var variant : int = 0;
var atlas := AtlasTexture.new();


func get_state() -> Dictionary:
	var dict = super.get_state();
	dict["shadowing"] = shadowing.duplicate();
	
	return dict;


func set_state(state: Dictionary) -> void:
	super.set_state(state);
	shadowing = state["shadowing"];


func _get_emission_directions() -> Array:
	var result := []
	for dir_num in shadowing.keys():
		result.push_back(Direction.from_num(dir_num));
	return result;


func _ready() -> void:
	match variant:
		0:
			custom_sprite = load("res://assets/box.png");
		1:
			custom_sprite = load("res://assets/screen.png");
		2:
			custom_sprite = atlas;
			atlas.atlas = preload("res://assets/objects/box_spritesheet.png");
			atlas.region.size = Vector2(64., 60.);
			atlas.region.position = Vector2(0., 0.);
		3:
			custom_sprite = atlas;
			atlas.atlas = preload("res://assets/objects/box_spritesheet.png");
			atlas.region.size = Vector2(64., 60.);
			atlas.region.position = Vector2(64., 0.);
	super._ready();


func _init() -> void:
	add_tag(TAGS.BEAM_SENSITIVE);
	add_tag(TAGS.BEAM_EMITTER);
	add_tag(TAGS.BEAM_STOPPER);
	add_tag(TAGS.PUSH);
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
