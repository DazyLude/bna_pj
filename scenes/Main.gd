extends Node
class_name MainScene
# this node handles level, UI and BGM loading


enum {
	LEVEL_TEST,
}


# _ = private variable
var _current_level : Node = null;
var _current_level_resourse : PackedScene = null;

var _modal_component : Node = null;
var _hud : HUD = null;
var paused : bool = true;


func _ready() -> void:
	var hud_pckd := preload("res://scenes/ui/hud.tscn");
	_hud = hud_pckd.instantiate();
	add_ui_component(_hud);
	
	var main_menu_pckd := preload("res://scenes/menus/main_menu.tscn");
	display_modal_component(main_menu_pckd.instantiate());
	


# these methods are avaialable in all children nodes using:
# 	get_tree().root.get_node("Main").load_level(MainScene.LEVEL_TEST);
# or like this:
#	(get_tree().root.get_node("Main") as MainScene).load_level(MainScene.LEVEL_TEST);


func load_level(level_id : int) -> void :
	match level_id:
		_:
			_current_level_resourse = preload("res://scenes/levels/test_level.tscn");
	
	unload_level();
	start_level();


func restart_level() -> void:
	unload_level();
	start_level();
	

func play_transition() -> void:
	($Transition/Label).text = _current_level.get_node("GameLevel").level_name;
	$Transition.play("fade_in");


func start_level() -> void :
	_current_level = _current_level_resourse.instantiate();
	play_transition();
	_hud.connect_to_level(_current_level.get_node("GameLevel"));
	$GameContainer.add_child(_current_level);
	paused = false;


func unload_level() -> void :
	if _current_level != null:
		_hud.disconnect_from_level(_current_level.get_node("GameLevel"));
		$GameContainer.remove_child(_current_level);
		_current_level.queue_free();
		_current_level = null;


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
