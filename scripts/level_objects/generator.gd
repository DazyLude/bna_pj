@tool
extends LevelObject
class_name Generator


func is_powered() -> bool:
	return true;


func _init() -> void:
	margin_from_bottom = 10.
	add_tag(TAGS.PUSH);
	

func _prepare_visuals() -> void:
	_sprite.texture = preload("res://assets/generator.png");
	margin_from_bottom = 10.;
	super._prepare_visuals();
