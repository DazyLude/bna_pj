@tool
extends LevelObject
class_name WallObject

func _init(invisible : bool = false):
	tags.push_back(TAGS.STOP);
	tags.push_back(TAGS.FLYING);
	tags.push_back(TAGS.BEAM_STOPPER);
	if !invisible:
		custom_sprite = load("res://assets/big_stone.png");


# Called when the node enters the scene tree for the first time.
func _ready():
	if custom_sprite != null:
		super._ready();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta);
