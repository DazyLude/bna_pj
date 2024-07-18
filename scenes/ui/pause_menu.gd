extends Control


var main_ref : MainScene = null;
var main_menu_pckd := preload("res://scenes/menus/main_menu.tscn");


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_ref = get_tree().root.get_node("Main") as MainScene;
	($ButtonsVBox/ResumeButton as BaseButton).button_up.connect(_continue);
	($ButtonsVBox/ExitButton as BaseButton).button_up.connect(_exit_to_the_menu);


func _continue() -> void:
	main_ref.remove_modal_component();


func _exit_to_the_menu() -> void:
	main_ref.display_modal_component(main_menu_pckd.instantiate());
