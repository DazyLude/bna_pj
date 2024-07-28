extends Node2D
class_name Intermission

var dialogue : Array[Phrase] = [];

var left_node : Node2D = null;
var left_position : Vector2;
var left_nudge : float = 1.;

var right_node : Node2D = null;
var right_position : Vector2;
var right_nudge : float = 1.;

var dialogue_index : int = -1;
var bubbles : Array[Node] = [];

const bubble_control_height := 520.;
const outer_side_margin := 320.;
const bubble_width := 310;
const bubble_padding := 5.;

const font_size := 28;

const bump_height := 20.;

var _main_ref : MainScene = null;
@export var _next_level_id : MainScene.LevelID = MainScene.LevelID.WIN_CONDITION_TUTORIAL;
@export var intermission_name : String = "Introduction";


func _ready() -> void:
	_main_ref = get_tree().root.get_node("Main") as MainScene;
	
	for child in get_children():
		if child as Phrase != null:
			dialogue.push_back(child)
			
	say_the_next_line();
	#call_deferred("adjust_height");


func bump_left() -> void:
	left_nudge = 0.;


func bump_right() -> void:
	right_nudge = 0.;


func spawn_bubble(text: String) -> Node:
	var t_panel : Panel = Panel.new();
	t_panel.size.x = bubble_width;
	
	var t_label : Label = Label.new();
	t_label.position = Vector2(bubble_padding, bubble_padding);
	t_label.text = text;
	t_label.size.x = bubble_width - 2. * bubble_padding;
	t_label.autowrap_mode = TextServer.AUTOWRAP_WORD;
	
	t_label.add_theme_font_size_override("font_size", font_size);
	
	t_panel.add_child(t_label);
	# this call is deferred because label parameters update not immidiately.
	self.call_deferred("set_height", t_label, t_panel);
	bubbles.push_back(t_panel);
	return t_panel;


func set_height(label : Label, panel : Panel) -> void:
	panel.size.y = label.size.y + bubble_padding * 2.;


func spawn_left_bubble(text: String) -> Node:
	var bubble = spawn_bubble(text);
	bubble.position.x = outer_side_margin;
	bubble.position.y = bubble_control_height;
	add_child(bubble);
	bump_left();
	call_deferred("adjust_height");
	return bubble;


func spawn_right_bubble(text: String) -> Node:
	var bubble = spawn_bubble(text);
	bubble.position.x = get_window().get_viewport().size.x - (outer_side_margin + bubble_width);
	bubble.position.y = bubble_control_height;
	add_child(bubble);
	bump_right();
	call_deferred("adjust_height");
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
		_:
			dialogue_index = -1;


func say_the_next_line() -> void:
	dialogue_index += 1;
	if dialogue_index < dialogue.size():
		say_the_line(dialogue[dialogue_index]);
	else:
		go_next();


func go_next() -> void:
	if (_main_ref != null):
		_main_ref.load_level(_next_level_id);


const animation_speed := 5.


func _process(delta: float) -> void:
	if _main_ref != null && _main_ref.paused:
		return;
	
	if left_node != null && left_nudge < 1.:
		left_nudge = min(left_nudge + delta * animation_speed, 1.);
		left_node.position = left_position.lerp(left_position + Vector2(0., -bump_height), sin(left_nudge * PI));
	
	if right_node != null && right_nudge < 1.:
		right_nudge = min(right_nudge + delta * animation_speed, 1.);
		right_node.position = right_position.lerp(right_position + Vector2(0., -bump_height), sin(right_nudge * PI));
	
	if Input.is_action_just_pressed("dialog_continue"):
		say_the_next_line();
