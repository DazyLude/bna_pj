@tool
extends LevelObject
class_name FloodLight


@export var active = false;
var atlas := AtlasTexture.new();


func _init() -> void:
	atlas.atlas = preload("res://assets/floodlights.png");
	atlas.region.size = Vector2(64., 64.);
	select_visual_orientation();


func select_visual_orientation() -> void:
	match direction.num:
		Direction.DOWN:
			atlas.region.position.x = 0.;
		Direction.UP:
			atlas.region.position.x = 64.;
		Direction.LEFT:
			atlas.region.position.x = 128;
		Direction.RIGHT:
			atlas.region.position.x = 192.;


func _ready() -> void:
	add_tag(TAGS.BEAM_EMITTER);
	add_tag(TAGS.PUSH);
	add_tag(TAGS.TRANSIENT);
	emitter_type = Beam.TYPE.NONE;
	custom_sprite = atlas;
	super._ready();


func _prepare_visuals() -> void:
	select_visual_orientation();


func change_direction(new_direction: Direction) -> void:
	super.change_direction(new_direction);
	select_visual_orientation();


func get_state() -> Dictionary:
	var tmp = super.get_state();
	tmp["active"] = active;
	return tmp;


func set_state(state: Dictionary) -> void:
	active = state["active"];
	super.set_state(state);


func _turn_tick() -> void:
	var self_coords = _level_ref.get_coords_of_an_object(self);
	active = false;
	for delta in Direction.cardinals:
		for obj in _level_ref.get_objects_by_coords(self_coords + delta) as Array[LevelObject]:
			if obj.has_method("is_powered"):
				active = obj.is_powered();
			if active:
				break;
		if active:
			break;

	if active:
		emitter_type = Beam.TYPE.LIGHT;
	else:
		emitter_type = Beam.TYPE.NONE;
	
	super._turn_tick();
