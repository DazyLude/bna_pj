@tool
extends LevelObject
class_name PitObject

func _init():
	tags.push_back(TAGS.STOP);
	margin_from_bottom = 0.;
	z_index = -1;
	custom_sprite = load("res://assets/terrain/hole.png");


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta);
