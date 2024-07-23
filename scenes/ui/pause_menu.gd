extends Control


var _main_ref : MainScene = null;
var main_menu_pckd := preload("res://scenes/menus/main_menu.tscn");


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	($ButtonsVBox/ResumeButton as BaseButton).button_up.connect(_continue);
	($ButtonsVBox/RestartButton as BaseButton).button_up.connect(_restart);
	($ButtonsVBox/ExitButton as BaseButton).button_up.connect(_exit_to_the_menu);


func _continue() -> void:
	_main_ref.paused = false;
	_main_ref.remove_modal_component();


func _restart() -> void:
	_main_ref.restart_level();
	_main_ref.remove_modal_component();


func _exit_to_the_menu() -> void:
	_main_ref.display_modal_component(main_menu_pckd.instantiate());


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel") && _main_ref.paused:
		_continue();
