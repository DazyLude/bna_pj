@tool
extends LevelObject
class_name WallObject

@export_enum("normal", "dark_door", "light_door", "column", "dark_stone") var variant : int = 0;
enum {
	NORMAL,
	DARK_DOOR,
	LIGHT_DOOR,
	COLUMN,
	DARK_STONE,
}

var atlas := AtlasTexture.new();
var invisible : bool = true;


func _init(l_invisible : bool = false):
	add_tag(TAGS.STOP);
	add_tag(TAGS.FLYING);
	add_tag(TAGS.BEAM_STOPPER);
	self.invisible = l_invisible;


# Called when the node enters the scene tree for the first time.
func _ready():
	if !invisible:
		match variant:
			NORMAL:
				custom_sprite = preload("res://assets/big_stone.png");
			DARK_DOOR:
				custom_sprite = atlas;
				atlas.atlas = preload("res://assets/terrain/doors.png");
				atlas.region.size = Vector2(64., 36.);
				atlas.region.position = Vector2(0., 0.);
			LIGHT_DOOR:
				custom_sprite = atlas;
				atlas.atlas = preload("res://assets/terrain/doors.png");
				atlas.region.size = Vector2(64., 36.);
				atlas.region.position = Vector2(64., 0.);
			COLUMN:
				custom_sprite = atlas;
				atlas.atlas = preload("res://assets/objects/obstacles_spritesheet.png");
				atlas.region.size = Vector2(64., 90.);
				atlas.region.position = Vector2(64., 0.);
			DARK_STONE:
				custom_sprite = atlas;
				atlas.atlas = preload("res://assets/objects/obstacles_spritesheet.png");
				atlas.region.size = Vector2(64., 90.);
				atlas.region.position = Vector2(0., 0.);
	if custom_sprite != null:
		super._ready();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta);
