extends Node
# this node handles level, UI and BGM loading


enum {
	LEVEL_TEST,
}


# _ = private variable
var _current_level : Node;


func _ready() -> void:
	#display main menu on first load;
	pass;


# @ $"/root/Main".load_level()
func load_level(level_id : int) -> void :
	var level_resource : PackedScene;
	match level_id:
		_:
			level_resource = preload("res://scenes/levels/test_level.tscn");
	
	if _current_level != null:
		$GameContainer.remove_child(_current_level);
		_current_level.queue_free();
		_current_level = null;
	
	_current_level = level_resource.instantiate();
	$GameContainer.add_child(_current_level);


