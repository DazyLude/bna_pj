extends Node2D
class_name Intermission

var dialogue : Array[Phrase] = [];
var dialogue_index : int = -1;

var left_node : Node2D = null;
var left_position : Vector2;
var left_nudge : float = 1.;

var right_node : Node2D = null;
var right_position : Vector2;
var right_nudge : float = 1.;

var bubbles : Array[Node] = [];

const bubble_control_height := 300.;

var _main_ref : MainScene = null;
@export var _next_level_id : int = 0;
@export var intermission_name : String = "Test Intermission"


func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	
	for child in get_children():
		if child as Phrase != null:
			dialogue.push_back(child)


func bump_left() -> void:
	left_nudge = 0.;


func bump_right() -> void:
	right_nudge = 0.;


func spawn_bubble(text: String) -> Node:
	var t_panel : Panel = Panel.new();
	t_panel.size.x = 310.;
	
	var t_label : Label = Label.new();
	t_label.position = Vector2(5., 5.);
	t_label.text = text;
	t_label.size.x = 300.;
	t_label.autowrap_mode = TextServer.AUTOWRAP_WORD;
	
	t_label.add_theme_font_size_override("font_size", 30);
	
	t_panel.add_child(t_label);
	# this call is deferred because label parameters update not immidiately.
	self.call_deferred("set_height", t_label, t_panel);
	bubbles.push_back(t_panel);
	add_child(t_panel);
	return t_panel;


func set_height(label : Label, panel : Panel) -> void:
	panel.size.y = label.size.y + 10.;


func spawn_left_bubble(text: String) -> Node:
	var bubble = spawn_bubble(text);
	bubble.position.x = 10.;
	bubble.position.y = bubble_control_height;
	bump_left();
	return bubble;


func spawn_right_bubble(text: String) -> Node:
	var bubble = spawn_bubble(text);
	bubble.position.x = get_window().get_viewport().size.x - (10. + bubble.size.x);
	bubble.position.y = bubble_control_height;
	bump_right();
	return bubble;


func adjust_height() -> void:
	var bubble_total_height = bubbles.reduce(
		func(accum, bubble): return accum + bubble.size.y,
		0.
	);
	var height_of_bubbles := 0.;
	for bubble in bubbles:
		bubble.position.y = bubble_control_height - bubble_total_height + height_of_bubbles;
		height_of_bubbles += bubble.size.y;
	

func say_the_line(phrase: Phrase) -> void:
	match phrase.side:
		0:
			if left_node != phrase.reaction:
				if left_node != null:
					left_node.visible = false;
				left_node = phrase.reaction;
				left_node.visible = true;
			
			left_position = left_node.position;
			spawn_left_bubble(phrase.text);
		1:
			if right_node != phrase.reaction:
				if right_node != null:
					right_node.visible = false;
				right_node = phrase.reaction;
				right_node.visible = true;
			
			right_position = right_node.position;
			spawn_right_bubble(phrase.text);


func say_the_next_line() -> void:
	dialogue_index += 1;
	if dialogue_index < dialogue.size():
		say_the_line(dialogue[dialogue_index]);
	else:
		go_next();


func go_next() -> void:
	_main_ref.load_level(_next_level_id);


const animation_speed := 10.


func _process(delta: float) -> void:
	adjust_height();
	
	if left_node != null && left_nudge < 1.:
		left_nudge = min(left_nudge + delta * animation_speed, 1.);
		left_node.position = left_position.lerp(left_position + Vector2(0., -20.), sin(left_nudge * PI));
	
	if right_node != null && right_nudge < 1.:
		right_nudge = min(right_nudge + delta * animation_speed, 1.);
		right_node.position = right_position.lerp(right_position + Vector2(0., -20.), sin(right_nudge * PI));
	
	if Input.is_action_just_pressed("undo"):
		say_the_next_line();
