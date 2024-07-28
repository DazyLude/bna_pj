@tool
extends LevelObject
class_name PoweredGate


@export var active : bool = false;
var atlas := AtlasTexture.new();

func _init() -> void:
	atlas.atlas = preload("res://assets/objects/powered_door.png");
	atlas.region.size = Vector2(64., 64.);
	add_tag(TAGS.TRANSIENT);


func _ready() -> void:
	custom_sprite = atlas;
	match [active, has_tag(TAGS.STOP)]:
		[true, true]:
			remove_tag(TAGS.STOP);
		[false, false]:
			add_tag(TAGS.STOP);
	select_visual();
	super._ready();


func select_visual() -> void:
	# I know that this below is cringe and silly
	# however you can add direction dependency to this method
	# and it will be less work to adapt the code when it's like this
	match active: 
		true:
			atlas.region.position.x = 0.;
		false:
			atlas.region.position.x = 64.;


func get_state() -> Dictionary:
	var tmp = super.get_state();
	tmp["active"] = active;
	return tmp;


func set_state(state: Dictionary) -> void:
	active = state["active"];
	match [active, has_tag(TAGS.STOP)]:
		[true, true]:
			remove_tag(TAGS.STOP);
			select_visual();
		[false, false]:
			add_tag(TAGS.STOP);
			select_visual();
	super.set_state(state);


func _prepare_visuals() -> void:
	select_visual();


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
	
	match [active, has_tag(TAGS.STOP)]:
		[true, true]:
			remove_tag(TAGS.STOP);
			select_visual();
		[false, false]:
			add_tag(TAGS.STOP);
			select_visual();
	
	super._turn_tick();
