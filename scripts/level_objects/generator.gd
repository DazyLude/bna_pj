@tool
extends LevelObject
class_name Generator


func is_powered() -> bool:
	return true;


func _ready() -> void:
	tags.push_back(TAGS.PUSH);
	tags.push_back(TAGS.HEAVY);
	super._ready();


func _prepare_visuals() -> void:
	_sprite.texture = preload("res://assets/generator.png");
	margin_from_bottom = 10.;
	super._prepare_visuals();
