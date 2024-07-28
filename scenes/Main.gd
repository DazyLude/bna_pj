extends Node
class_name MainScene
# this node handles level, UI and BGM loading


enum LevelID {
	LEVEL_TEST,
	INTERMISSION_TEST,
	
	INTRODUCTION,
	INTERMISSION_1,
	INTERMISSION_2,
	INTERMISSION_3,
	INTERMISSION_4,
	INTERMISSION_5,
	INTERMISSION_6,
	EPILOGUE,
	
	WIN_CONDITION_TUTORIAL,
	BOXES_TUTORIAL,
	GATES_TUTORIAL,
	SHADOWS_TUTORIAL,
	FLIGHT_TUTORIAL,
	SOLAR_TUTORIAL,
	MIRROR_TUTORIAL,
}


func setup_scene(level_id: LevelID) -> void:
	match level_id:
		LevelID.LEVEL_TEST:
			_current_level_resourse = preload("res://scenes/levels/boxes_tutorial.tscn");
			_current_state = LEVEL;
		LevelID.INTERMISSION_TEST:
			_current_level_resourse = preload("res://scenes/intermissions/test_intermission.tscn");
			_current_state = INTERMISSION;
			
		LevelID.INTRODUCTION:
			_current_level_resourse = preload("res://scenes/intermissions/introduction.tscn");
			_current_state = INTERMISSION;
		LevelID.INTERMISSION_1:
			_current_level_resourse = preload("res://scenes/intermissions/intermission1.tscn");
			_current_state = INTERMISSION;
		LevelID.INTERMISSION_2:
			_current_level_resourse = preload("res://scenes/intermissions/intermission2.tscn");
			_current_state = INTERMISSION;
		LevelID.INTERMISSION_3:
			_current_level_resourse = preload("res://scenes/intermissions/intermission3.tscn");
			_current_state = INTERMISSION;
		LevelID.INTERMISSION_4:
			_current_level_resourse = preload("res://scenes/intermissions/intermission4.tscn");
			_current_state = INTERMISSION;
		LevelID.INTERMISSION_5:
			_current_level_resourse = preload("res://scenes/intermissions/intermission5.tscn");
			_current_state = INTERMISSION;
		LevelID.INTERMISSION_6:
			_current_level_resourse = preload("res://scenes/intermissions/intermission6.tscn");
			_current_state = INTERMISSION;
		
		LevelID.WIN_CONDITION_TUTORIAL:
			_current_level_resourse = preload("res://scenes/levels/win_condition_tutorial.tscn");
			_current_state = LEVEL;
		LevelID.BOXES_TUTORIAL:
			_current_level_resourse = preload("res://scenes/levels/boxes_tutorial.tscn");
			_current_state = LEVEL;
		LevelID.GATES_TUTORIAL:
			_current_level_resourse = preload("res://scenes/levels/gates_tutorial.tscn");
			_current_state = LEVEL;
		LevelID.SHADOWS_TUTORIAL:
			_current_level_resourse = preload("res://scenes/levels/shadows_tutorial.tscn");
			_current_state = LEVEL;
		LevelID.SOLAR_TUTORIAL:
			_current_level_resourse = preload("res://scenes/levels/solar_panels_tutorial.tscn");
			_current_state = LEVEL;
		LevelID.FLIGHT_TUTORIAL:
			_current_level_resourse = preload("res://scenes/levels/flight_tutorial.tscn");
			_current_state = LEVEL;
		LevelID.MIRROR_TUTORIAL:
			_current_level_resourse = preload("res://scenes/levels/mirrors_tutorial.tscn");
			_current_state = LEVEL;


# _ = private variable
var _current_level : Node = null;
var _current_level_resourse : PackedScene = null;
enum {
	LEVEL,
	INTERMISSION,
}
var _current_state : int;

var _modal_component : Node = null;
var _hud : HUD = null;
var paused : bool = true;


var sfx_player := AudioStreamPlayer.new();
var main_music : AudioStream = null;


func _ready() -> void:
	add_child(sfx_player);
	sfx_player.bus = "music";
	main_music = preload("res://assets/music/demo2.mp3");
	sfx_player.stream = main_music;
	sfx_player.finished.connect(func(): sfx_player.play());
	sfx_player.play();
	
	var hud_pckd := preload("res://scenes/ui/hud.tscn");
	_hud = hud_pckd.instantiate();
	add_ui_component(_hud);
	_hud.visible = false;
	
	var main_menu_pckd := preload("res://scenes/menus/main_menu.tscn");
	display_modal_component(main_menu_pckd.instantiate());
	


# these methods are avaialable in all children nodes using:
# 	get_tree().root.get_node("Main").load_level(MainScene.LEVEL_TEST);
# or like this:
#	(get_tree().root.get_node("Main") as MainScene).load_level(MainScene.LEVEL_TEST);


func load_level(level_id : LevelID) -> void :
	fade_out();
	await get_tree().create_timer(0.2).timeout;
	unload_level();
	
	setup_scene(level_id);
	
	start_level();
	fade_in();


func restart_level() -> void:
	unload_level();
	start_level();
	

func fade_in() -> void:
	match _current_state:
		LEVEL:
			($Transition/Label).text = _current_level.get_node("GameLevel").level_name;
		INTERMISSION:
			($Transition/Label).text = _current_level.get_node("Intermission").intermission_name;
	$Transition.play("fade_in");


func fade_out() -> void:
	$Transition.play("fade_out");


func start_level() -> void :
	_current_level = _current_level_resourse.instantiate();
	match _current_state:
		LEVEL:
			_hud.visible = true;
			_hud.connect_to_level(_current_level.get_node("GameLevel"));
			$GameContainer.add_child(_current_level);
		INTERMISSION:
			$GameContainer.add_child(_current_level);
	paused = false;


func unload_level() -> void :
	_hud.visible = false;
	if _current_level != null:
		match _current_state:
			LEVEL:
				_hud.disconnect_from_level(_current_level.get_node("GameLevel"));
				$GameContainer.remove_child(_current_level);
			INTERMISSION:
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
