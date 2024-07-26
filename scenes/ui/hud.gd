extends Control
class_name HUD


var _main_ref : MainScene = null;
var pause_menu_pckd := preload("res://scenes/ui/pause_menu.tscn");


func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	($PauseButton as BaseButton).button_up.connect(_show_pause_menu);


func connect_to_level(level_node: GameLevel) -> void:
	_selected_character_update(level_node.selected_character);
	level_node.changed_selected_character.connect(_selected_character_update);


func disconnect_from_level(_level_node: GameLevel) -> void:
	pass;


func _show_pause_menu() -> void:
	if _main_ref == null:
		return;
	($PauseButton as Control).release_focus();
	_main_ref.paused = true;
	_main_ref.display_modal_component(pause_menu_pckd.instantiate());


func _selected_character_update(selected_character: GameLevel.CHARACTER_ID = 0) -> void:
	pass;


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel") && !_main_ref.paused:
		_show_pause_menu();
