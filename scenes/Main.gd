extends Node
class_name MainScene
# this node handles level, UI and BGM loading


enum {
	LEVEL_TEST,
}


# _ = private variable
var _current_level : Node;
var _modal_component : Node;


func _ready() -> void:
	var main_menu_pckd := preload("res://scenes/menus/main_menu.tscn");
	var main_menu = main_menu_pckd.instantiate();
	display_modal_component(main_menu);


# these methods are avaialable in all children nodes using:
# 	get_tree().root.get_node("Main").load_level(MainScene.LEVEL_TEST);
# or like this:
#	(get_tree().root.get_node("Main") as MainScene).load_level(MainScene.LEVEL_TEST);


func load_level(level_id : int) -> void :
	var level_resource : PackedScene;
	match level_id:
		_:
			level_resource = preload("res://scenes/levels/test_level.tscn");
	
	if _current_level != null:
		$GameContainer.remove_child(_current_level);
		_current_level.queue_free();
		_current_level = null;
	
	_current_level = level_resource.instantiate();
	$GameContainer.add_child(_current_level);


func add_ui_component(component: Control) -> void :
	$UIContainer.add_child(component);


func clean_ui() -> void :
	for child in $UIContainer.get_children():
		$UIContainer.remove_child(child);
		child.queue_free();
		child = null;


func display_modal_component(component: Control) -> void :
	add_ui_component(component);
	if _modal_component != null:
		remove_modal_component();
	_modal_component = component;


func remove_modal_component() -> void :
	if _modal_component != null:
		$UIContainer.remove_child(_modal_component);
		_modal_component.queue_free();
		_modal_component = null;
