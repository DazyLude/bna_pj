extends Control
class_name HUD


var main_ref : MainScene = null;
var pause_menu_pckd := preload("res://scenes/ui/pause_menu.tscn");


func _ready() -> void:
	main_ref = get_tree().root.get_node("Main") as MainScene;
	($PauseButton as BaseButton).button_down.connect(_show_pause_menu)


func connect_to_level(level_node: GameLevel) -> void:
	($LevelName as Label).text = level_node.level_name;


func disconnect_from_level(level_node: GameLevel) -> void:
	($LevelName as Label).text = "no level";


func _show_pause_menu() -> void:
	if main_ref == null:
		return;
	main_ref.display_modal_component(pause_menu_pckd.instantiate());
