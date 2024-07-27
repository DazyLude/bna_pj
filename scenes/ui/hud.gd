extends Control
class_name HUD


var _main_ref : MainScene = null;
var pause_menu_pckd := preload("res://scenes/ui/pause_menu.tscn");

enum {
	_STOP,
	_MOVE,
}
var _movement_mode = _STOP;
var _movement_progress : float = 0.;
const _movement_speed_multiplier : float = 5.; # 1/ms
var _selected_character = null;
var _arya_start_position = null;
var _alta_start_position = null;
var delta_x = Vector2(150., 0.);
var delta_y = Vector2(0., 100.)
var _arya_end_position : Vector2;
var _alta_end_position : Vector2;
var _tmp_arya = null;
var _tmp_alta = null;

func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	($PauseButton as BaseButton).button_up.connect(_show_pause_menu);
	_arya_start_position = $AryaChar.position;
	_arya_end_position = _arya_start_position + delta_x - delta_y;
	_alta_start_position = $AltaChar.position;
	_alta_end_position = _alta_start_position - delta_x - delta_y;


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
	_movement_mode = _MOVE;
	_movement_progress = 0.;
	_selected_character = selected_character;
	_tmp_arya = $AryaChar.position;
	_tmp_alta = $AltaChar.position;


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel") && !_main_ref.paused:
		_show_pause_menu();
	
	if _movement_mode != _STOP:
		if _movement_progress < 1.:
			_movement_progress = minf(_movement_progress + _delta * _movement_speed_multiplier, 1.);
			if _selected_character == 1:
				$AryaChar.position = _tmp_arya.lerp(_arya_end_position, smoothstep(0., 1., _movement_progress));
				$AltaChar.position = _tmp_alta.lerp(_alta_start_position, smoothstep(0., 1., _movement_progress));
			else:
				$AltaChar.position = _tmp_alta.lerp(_alta_end_position, smoothstep(0., 1., _movement_progress));
				$AryaChar.position = _tmp_arya.lerp(_arya_start_position, smoothstep(0., 1., _movement_progress));
		else:
			_movement_mode = _STOP;
