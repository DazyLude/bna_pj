@tool
extends LevelObject
class_name ExitObject

var atlas := AtlasTexture.new();

func _init():
	atlas.atlas = preload("res://assets/objects/exit_arrow.png");
	atlas.region.size = Vector2(64., 64.);
	select_visual_orientation();
	z_index = -1;
	
	tags.push_back(TAGS.WIN);


func select_visual_orientation() -> void:
	match direction.num:
		Direction.UP:
			atlas.region.position.x = 0;
		Direction.LEFT:
			atlas.region.position.x = 64.;
		Direction.DOWN:
			atlas.region.position.x = 128.;
		Direction.RIGHT:
			atlas.region.position.x = 192.;


func _ready() -> void:
	custom_sprite = atlas;
	super._ready();


func _prepare_visuals() -> void:
	return;
