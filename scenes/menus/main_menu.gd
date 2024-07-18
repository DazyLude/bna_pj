extends Control


var help_pckd := preload("res://scenes/menus/help.tscn");
var select_pckd := preload("res://scenes/menus/level_select.tscn");
var main_ref : MainScene = null;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	($ButtonsVBox/NewGameButton as BaseButton).button_up.connect(_start_game);
	($ButtonsVBox/LoadLevelButton as BaseButton).button_up.connect(_open_level_select);
	($ButtonsVBox/DisplayHelpButton as BaseButton).button_up.connect(_open_help);
	main_ref = get_tree().root.get_node("Main") as MainScene;


func _start_game() -> void:
	main_ref.load_level(MainScene.LEVEL_TEST);
	main_ref.remove_modal_component();


func _open_help() -> void:
	main_ref.display_modal_component(help_pckd.instantiate());


func _open_level_select() -> void:
	main_ref.display_modal_component(select_pckd.instantiate());
