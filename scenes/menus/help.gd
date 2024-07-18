extends Control


var main_pckd := preload("res://scenes/menus/main_menu.tscn");
var main_ref : MainScene = null;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_ref = get_tree().root.get_node("Main") as MainScene;
	($BackButton as BaseButton).button_up.connect(_back_to_menu);


func _back_to_menu() -> void:
	main_ref.display_modal_component(main_pckd.instantiate());
