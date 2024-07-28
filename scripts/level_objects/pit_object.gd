@tool
extends LevelObject
class_name PitObject


enum {
	DARK_TOP,
	DARK_BOTTOM,
	LIGHT_TOP,
	LIGHT_BOTTOM,
	MIDDLE_TOP,
	MIDDLE_BOTTOM,
	ABYSS,
}
@export_enum("dark_top", "dark_bottom", "light_top", "light_bottom", "middle_top", "middle_bottom", "abyss") var variant : int = ABYSS;
var atlas := AtlasTexture.new();


func _init():
	atlas.atlas = preload("res://assets/objects/hole_spreadsheet.png");
	atlas.region.size = Vector2(64., 64.);
	add_tag(TAGS.STOP);
	margin_from_bottom = 0.;
	z_index = -1;


func _ready() -> void:
	custom_sprite = atlas;
	super._ready();
	select_variant();


func select_variant() -> void:
	match variant:
		DARK_TOP:
			atlas.region.position = Vector2(0., 0.);
		DARK_BOTTOM:
			atlas.region.position = Vector2(64., 0.);
		LIGHT_TOP:
			atlas.region.position = Vector2(64., 64.);
		LIGHT_BOTTOM:
			atlas.region.position = Vector2(0., 128.);
		MIDDLE_TOP:
			atlas.region.position = Vector2(0., 192.);
		MIDDLE_BOTTOM:
			atlas.region.position = Vector2(64., 192.);
		ABYSS, _:
			atlas.region.position = Vector2(0., 64.);
