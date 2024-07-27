@tool
extends LevelObject
class_name PoweredGate


@export var active : bool = false;
var atlas := AtlasTexture.new();

func _init() -> void:
	atlas.atlas = preload("res://assets/objects/powered_door.png");
	atlas.region.size = Vector2(64., 64.);
	tags.push_back(TAGS.TRANSIENT);
	select_visual();


func select_visual() -> void:
	# I know that this below is cringe and silly
	# however you can add direction dependency to this method
	# and it will be less work to adapt the code when it's like this
	match active: 
		true:
			atlas.region.position.x = 0.;
		false:
			atlas.region.position.x = 64.;


func _ready() -> void:
	custom_sprite = atlas;
	super._ready();


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
			tags.erase(TAGS.STOP);
			select_visual();
		[false, false]:
			tags.push_back(TAGS.STOP);
			select_visual();
	
	super._turn_tick();
