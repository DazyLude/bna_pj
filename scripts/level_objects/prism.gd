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
		vertical_direction = new_v;
		_vertical_direction = new_v;


var atlas := AtlasTexture.new();
enum {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
}
func select_visual_orientation() -> void:
	var variant : int; 
	
	match [vertical_direction, horizontal_direction]:
		[Direction.UP, Direction.LEFT]:
			variant = TOP_LEFT;
		[Direction.UP, Direction.RIGHT]:
			variant = TOP_RIGHT;
		[Direction.DOWN, Direction.LEFT]:
			variant = BOTTOM_LEFT;
		[Direction.DOWN, Direction.RIGHT]:
			variant = BOTTOM_RIGHT;
	
	match variant:
		TOP_RIGHT:
			atlas.region.position.x = 0;
		TOP_LEFT:
			atlas.region.position.x = 64.;
		BOTTOM_RIGHT:
			atlas.region.position.x = 128.;
		BOTTOM_LEFT:
			atlas.region.position.x = 192.;


func _get_emission_directions() -> Array:
	var result := []
	for dir_num in reflecting.keys():
		result.push_back(Direction.from_num(dir_num));
	return result;


func _init() -> void:
	atlas.atlas = preload("res://assets/objects/mirror.png");
	atlas.region.size = Vector2(64., 64.);
	
	tags.push_back(TAGS.BEAM_SENSITIVE);
	tags.push_back(TAGS.BEAM_EMITTER);
	tags.push_back(TAGS.BEAM_STOPPER);
	tags.push_back(TAGS.PUSH);
	
	emitter_type = Beam.TYPE.NONE;


func get_state() -> Dictionary:
	var tmp = super.get_state();
	tmp["horizontal_direction"] = horizontal_direction;
	tmp["vertical_direction"] = vertical_direction;
	return tmp;


func set_state(state: Dictionary) -> void:
	vertical_direction = state["vertical_direction"];
	horizontal_direction = state["horizontal_direction"];
	super.set_state(state);


func _prepare_visuals() -> void:
	_sprite.texture = atlas;
	select_visual_orientation();


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
	
	select_visual_orientation();
	
	super.change_direction(new_direction);
