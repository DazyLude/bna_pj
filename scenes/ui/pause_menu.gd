extends Control


var _main_ref : MainScene = null;
var main_menu_pckd := preload("res://scenes/menus/main_menu.tscn");
var sound_max := preload("res://assets/icons/sound-max-svgrepo-com.svg")
var sound_mute := preload("res://assets/icons/sound-mute-alt-svgrepo-com.svg");


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	if _main_ref._current_state == _main_ref.LEVEL:
		var _level_ref : GameLevel = _main_ref._current_level.get_node("GameLevel");
		$LevelName.text = _level_ref.level_name;
		$ButtonsVBox/SkipButton.button_up.connect(
			func():
				_level_ref.go_next();
				_continue();
		);
	else:
		$LevelName.text = _main_ref._current_level.get_node("Intermission").intermission_name;
		$ButtonsVBox/SkipButton.visible = false;
	
	($ButtonsVBox/ResumeButton as BaseButton).button_up.connect(_continue);
	($ButtonsVBox/RestartButton as BaseButton).button_up.connect(_restart);
	($ButtonsVBox/ExitButton as BaseButton).button_up.connect(_exit_to_the_menu);
	
	
	
	($Mute as Button).button_up.connect(_mute);


func _continue() -> void:
	_main_ref.paused = false;
	_main_ref.remove_modal_component();


func _restart() -> void:
	_main_ref.restart_level();
	_main_ref.remove_modal_component();


func _exit_to_the_menu() -> void:
	_main_ref.music_fadeout(false);
	_main_ref.display_modal_component(main_menu_pckd.instantiate());


func _mute() -> void:
	($Mute as Button).release_focus();
	AudioServer.set_bus_mute(2, not AudioServer.is_bus_mute(2));
	if AudioServer.is_bus_mute(2):
		$Mute.icon = sound_mute;
	else:
		$Mute.icon = sound_max;


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel") && _main_ref.paused:
		_continue();
