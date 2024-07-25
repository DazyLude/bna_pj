@tool
extends LevelObject
class_name AryaObject

var animated_sprite: AnimatedSprite2D = AnimatedSprite2D.new();

var sfx_player := AudioStreamPlayer.new();
var move_fx : AudioStream = null;
var nudge_fx : AudioStream = null;


func _init():
	add_child(sfx_player);
	sfx_player.bus = "sfx";
	
	tags.push_back(TAGS.ARYA);
	tags.push_back(TAGS.PUSH);
	tags.push_back(TAGS.LIGHT);
	
	animated_sprite.sprite_frames = preload("res://assets/animations/arya_sprite_frames.tres");
	move_fx = preload("res://assets/sfx/whoop_h.wav");
	nudge_fx = preload("res://assets/sfx/poowh_h.wav");


func _ready():
	animated_sprite.position = self._starting_position;
	animated_sprite.centered = false;
	
	add_child(animated_sprite);

	
func _prepare_visuals() -> void:
	var diff =  _level_ref.cell_size - self.animated_sprite.sprite_frames\
		.get_frame_texture("walk", 0).get_size();
	animated_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);


func change_direction(new_direction: Direction) -> void:
	if new_direction.num == Direction.LEFT && direction.num != Direction.LEFT:
		animated_sprite.flip_h = true;
	if new_direction.num == Direction.RIGHT && direction.num != Direction.RIGHT:
		animated_sprite.flip_h = false;
	if new_direction.num != Direction.NONE || !new_direction.equals(direction):
		direction = new_direction;


func nudge(to: Vector2) -> void:
	var pitch_mod = 1. + .1 * (randf() - 0.5);
	sfx_player.pitch_scale = pitch_mod;
	sfx_player.stream = nudge_fx;
	sfx_player.play();
	super.nudge(to);


func move_to(to: Vector2) -> void:
	var pitch_mod = 1. + .1 * (randf() - 0.5);
	sfx_player.pitch_scale = pitch_mod;
	sfx_player.stream = move_fx;
	sfx_player.play();
	super.move_to(to);
