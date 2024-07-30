extends Control


var main_pckd := preload("res://scenes/menus/main_menu.tscn");
var _main_ref : MainScene = null;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	($ButtonsGrid/Level1 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.WIN_CONDITION_TUTORIAL)
	);
	($ButtonsGrid/Level2 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.BOXES_TUTORIAL)
	);
	($ButtonsGrid/Level3 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.GATES_TUTORIAL)
	);
	($ButtonsGrid/shadows as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.SHADOWS_TUTORIAL)
	);
	($ButtonsGrid/Level5 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.FLIGHT_TUTORIAL)
	);
	($ButtonsGrid/Level6 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.STRENGTH_TUTORIAL)
	);
	($ButtonsGrid/Level7 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.DEJA_VU)
	);
	($ButtonsGrid/Level8 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.LEVEL_1)
	);
	($ButtonsGrid/Level9 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.LEVEL_2)
	);
	($ButtonsGrid/Level10 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.MIRROR_TUTORIAL)
	);
	($ButtonsGrid/Level11 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.LEVEL_3)
	);
	($ButtonsGrid/Level12 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.SOLAR_TUTORIAL)
	);
	($ButtonsGrid/Level13 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.LEVEL_4)
	);
	($ButtonsGrid/Level14 as BaseButton).button_up.connect(
		func(): _load_level(MainScene.LevelID.LEVEL_THE_FINAL)
	);
	
	

	#FLIGHT_TUTORIAL,
	#STRENGTH_TUTORIAL,
	#MIRROR_TUTORIAL,
	#SOLAR_TUTORIAL,
	#
	#LEVEL_1,
	#LEVEL_2,
	#LEVEL_3,
	#LEVEL_4,
	#
	#LEVEL_THE_FINAL,
	#
	#DEJA_VU,
	($BackButton as BaseButton).button_up.connect(_back_to_menu);


func _back_to_menu() -> void:
	_main_ref.display_modal_component(main_pckd.instantiate());


func _load_level(level_id) -> void:
	_main_ref.load_level(level_id);
	_main_ref.remove_modal_component();


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		_back_to_menu();
