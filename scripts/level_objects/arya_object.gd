extends LevelObject
class_name AryaObject


func _init():
	tags.push_back(TAGS.ARYA);
	tags.push_back(TAGS.PUSH);
	tags.push_back(TAGS.LIGHT);
	custom_sprite = load("res://assets/gyaru.png");


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta);
