@tool
extends LevelObject
class_name AryaObject

var animated_sprite : AnimatedSprite2D = AnimatedSprite2D.new();
var powered_up_sprite : AnimatedSprite2D = AnimatedSprite2D.new();

var sfx_player := AudioStreamPlayer.new();
var move_fx : AudioStream = null;
var nudge_fx : AudioStream = null;

var in_the_shadow : bool = false;
var lit : bool = false;

var powered_up : bool = false;
var desired_powered_up : bool = false;

var animation_state : int = IDLE_DOWN;
var desired_state : int;

enum {
	STUCK,
	WALK_LEFT,
	WALK_RIGHT,
	WALK_UP,
	WALK_DOWN,
	IDLE_LEFT,
	IDLE_RIGHT,
	IDLE_UP,
	IDLE_DOWN,
}


func _init():
	add_child(sfx_player);
	sfx_player.bus = "sfx";
	
	add_tag(TAGS.ARYA);
	add_tag(TAGS.PUSH);
	add_tag(TAGS.BEAM_SENSITIVE);
	add_tag(TAGS.TRANSIENT);
	
	animated_sprite.sprite_frames = preload("res://assets/animations/arya_sprite_frames.tres");
	powered_up_sprite.sprite_frames = preload("res://assets/animations/kamekamehaaa.tres");
	
	move_fx = preload("res://assets/sfx/whoop_h.wav");
	nudge_fx = preload("res://assets/sfx/poowh_h.wav");
	margin_from_bottom = 10.;


func _ready():
	animated_sprite.position = self._starting_position;
	animated_sprite.centered = false;
	add_child(animated_sprite);
	
	powered_up_sprite.position = self._starting_position;
	powered_up_sprite.centered = false;
	add_child(powered_up_sprite);

	
func _prepare_visuals() -> void:
	var diff =  _level_ref.cell_size - self.animated_sprite.sprite_frames\
		.get_frame_texture("idle_down", 0).get_size();
	animated_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);
	powered_up_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom * 2);


func nudge(from: Vector2, to: Vector2) -> void:
	var pitch_mod = 1. + .1 * (randf() - 0.5);
	sfx_player.pitch_scale = pitch_mod;
	sfx_player.stream = nudge_fx;
	sfx_player.play();
	super.nudge(from, to);


func move_to(to: Vector2) -> void:
	var pitch_mod = 1. + .1 * (randf() - 0.5);
	sfx_player.pitch_scale = pitch_mod;
	sfx_player.stream = move_fx;
	sfx_player.play();
	super.move_to(to);


func _light_tick() -> bool:
	var l_lit := false;
	var shadowed := false;
	
	for beam in beamed_on_by.keys():
		if beam.btype == Beam.TYPE.LIGHT:
			l_lit = true;
		if beam.btype == Beam.TYPE.SHADOW:
			shadowed = true;
	
	in_the_shadow = shadowed && !l_lit;
	self.lit = l_lit;
	
	match [l_lit, has_tag(TAGS.STRONG)]:
		[true, false]:
			desired_powered_up = true;
			add_tag(TAGS.STRONG);
		[false, true]:
			desired_powered_up = false;
			remove_tag(TAGS.STRONG);
	
	super._light_tick();
	return false;


func _turn_tick() -> void:
	var self_coords := _level_ref.get_coords_of_an_object(self);
	var objects_in_the_cell := _level_ref.get_objects_by_coords(self_coords);
	stuck = false;
	
	for object in objects_in_the_cell as Array[LevelObject]:
		if (
			(object.has_tag(LevelObject.TAGS.STOP) &&  !self.has_tag(LevelObject.TAGS.FLYING)) ||
			(object.has_tag(LevelObject.TAGS.STOP) && object.has_tag(LevelObject.TAGS.FLYING))
		):
			stuck = true;
	
	if in_the_shadow:
		stuck = true;
	
	match [stuck, _movement_mode, _direction]:
		[true, _, _]:
			desired_state = STUCK;
		# up
		[false, _MOVE, Direction.UP], [false, _NUDGE, Direction.UP]:
			desired_state = WALK_UP;
		[false, _STOP, Direction.UP]:
			desired_state = IDLE_UP;
		# left
		[false, _MOVE, Direction.LEFT], [false, _NUDGE, Direction.LEFT]:
			desired_state = WALK_LEFT;
		[false, _STOP, Direction.LEFT]:
			desired_state = IDLE_LEFT;
		# right
		[false, _MOVE, Direction.RIGHT], [false, _NUDGE, Direction.RIGHT]:
			desired_state = WALK_RIGHT;
		[false, _STOP, Direction.RIGHT]:
			desired_state = IDLE_RIGHT;
		# down
		[false, _MOVE, Direction.DOWN], [false, _NUDGE, Direction.DOWN]:
			desired_state = WALK_DOWN;
		[false, _STOP, Direction.DOWN]:
			desired_state = IDLE_DOWN;



func _process(delta: float) -> void:
	if desired_state != animation_state:
		animation_state = desired_state;
		match desired_state:
			STUCK:
				animated_sprite.play(&"stuck");
			WALK_LEFT:
				animated_sprite.play(&"walk_left");
			WALK_RIGHT:
				animated_sprite.play(&"walk_right");
			WALK_UP:
				animated_sprite.play(&"walk_up");
			WALK_DOWN:
				animated_sprite.play(&"walk_down");
			IDLE_LEFT:
				animated_sprite.play(&"idle_left");
			IDLE_RIGHT:
				animated_sprite.play(&"idle_right");
			IDLE_UP:
				animated_sprite.play(&"idle_up");
			IDLE_DOWN:
				animated_sprite.play(&"idle_down");
	
	if powered_up != desired_powered_up:
		powered_up = desired_powered_up;
		if powered_up:
			powered_up_sprite.play(&"powered_up");
		else:
			powered_up_sprite.play(&"empty");
	
	super._process(delta);
