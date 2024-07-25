@tool
extends LevelObject
class_name ExitObject



func _init():
	tags.push_back(TAGS.WIN);


func _ready() -> void:
	if Engine.is_editor_hint():
		custom_sprite = preload("res://assets/7070ph.png");
		super._ready();


func _prepare_visuals() -> void:
	return;
