extends Control


var main_pckd := preload("res://scenes/menus/main_menu.tscn");
var _main_ref : MainScene = null;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	($ButtonsGrid/TestLevelButton as BaseButton).button_up.connect(func(): _load_level(MainScene.LEVEL_TEST));
	($BackButton as BaseButton).button_up.connect(_back_to_menu);


func _back_to_menu() -> void:
	_main_ref.display_modal_component(main_pckd.instantiate());


func _load_level(level_id) -> void:
	_main_ref.load_level(level_id);
	_main_ref.remove_modal_component();


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		_back_to_menu();
