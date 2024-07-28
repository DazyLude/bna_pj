@tool
extends LevelObject
class_name AltaObject

var animated_sprite: AnimatedSprite2D = AnimatedSprite2D.new();
var in_the_shadow : bool = false;
var lit : bool = false;

enum {
	WALK_LEFT,
	WALK_RIGHT,
	WALK_UP,
	WALK_DOWN,
	IDLE_LEFT,
	IDLE_RIGHT,
	IDLE_UP,
	IDLE_DOWN,
	STUCK,
	FLY,
}

var animation_state : int = IDLE_DOWN;

var sfx_player := AudioStreamPlayer.new();
var move_fx : AudioStream = null;
var nudge_fx : AudioStream = null;


func _init():
	add_child(sfx_player);
	sfx_player.bus = "sfx";
	
	add_tag(TAGS.ALTA);
	add_tag(TAGS.PUSH);
	add_tag(TAGS.BEAM_SENSITIVE);
	add_tag(TAGS.TRANSIENT);
	
	margin_from_bottom = 11.;
	
	animated_sprite.sprite_frames = preload("res://assets/animations/alta_sprite_frames.tres");
	move_fx = preload("res://assets/sfx/whoop3.wav");
	nudge_fx = preload("res://assets/sfx/poowh.wav");


func _ready():
	animated_sprite.position = self._starting_position;
	animated_sprite.centered = false;
	add_child(animated_sprite);
	animated_sprite.play(&"idle_down");


func _prepare_visuals() -> void:
	var diff =  _level_ref.cell_size - self.animated_sprite.sprite_frames\
		.get_frame_texture("idle_down", 0).get_size();
	animated_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);


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
	
	match [in_the_shadow, has_tag(TAGS.FLYING)]:
		[true, false]:
			add_tag(TAGS.FLYING);
		[false, true]:
			remove_tag(TAGS.FLYING);
	
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
	
	if lit:
		stuck = true;


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


func _process(delta: float) -> void:
	var desired_state : int;
	match [stuck, _movement_mode, _direction, in_the_shadow]:
		[true, _, _, _]:
			desired_state = STUCK;
		[false, _, _, true]:
			desired_state = FLY;
		# up
		[false, _MOVE, Direction.UP, _], [false, _NUDGE, Direction.UP, _]:
			desired_state = WALK_UP;
		[false, _STOP, Direction.UP, _]:
			desired_state = IDLE_UP;
		# left
		[false, _MOVE, Direction.LEFT, _], [false, _NUDGE, Direction.LEFT, _]:
			desired_state = WALK_LEFT;
		[false, _STOP, Direction.LEFT, _]:
			desired_state = IDLE_LEFT;
		# right
		[false, _MOVE, Direction.RIGHT, _], [false, _NUDGE, Direction.RIGHT, _]:
			desired_state = WALK_RIGHT;
		[false, _STOP, Direction.RIGHT, _]:
			desired_state = IDLE_RIGHT;
		# down
		[false, _MOVE, Direction.DOWN, _], [false, _NUDGE, Direction.DOWN, _]:
			desired_state = WALK_DOWN;
		[false, _STOP, Direction.DOWN, _]:
			desired_state = IDLE_DOWN;
	
	if desired_state != animation_state:
		animation_state = desired_state;
		match desired_state:
			FLY:
				animated_sprite.play(&"fly");
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
	super._process(delta);
