@tool
extends LevelObject
class_name AltaObject

var animated_sprite: AnimatedSprite2D = AnimatedSprite2D.new();
var in_the_shadow : bool = false;

enum {
	WALK,
	FLY,
}
var animation_state : int = WALK;


func _init():
	tags.push_back(TAGS.ALTA);
	tags.push_back(TAGS.PUSH);
	tags.push_back(TAGS.LIGHT);
	tags.push_back(TAGS.BEAM_SENSITIVE);


func _ready():
	animated_sprite.position = self._starting_position;
	animated_sprite.centered = false;
	animated_sprite.sprite_frames = load("res://assets/animations/alta_sprite_frames.tres");
	add_child(animated_sprite);
	animated_sprite.play(&"walk");


func place_on_level(starting_position: Vector2, level: GameLevel) -> void:
	position = starting_position;
	
	_starting_position = starting_position;
	_desired_position = starting_position;
	var diff =  level.cell_size - self.animated_sprite.sprite_frames\
		.get_frame_texture("walk", 0).get_size();
	animated_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);


func change_direction(new_direction: Direction) -> void:
	if new_direction.num == Direction.LEFT && direction.num != Direction.LEFT:
		animated_sprite.flip_h = true;
	if new_direction.num == Direction.RIGHT && direction.num != Direction.RIGHT:
		animated_sprite.flip_h = false;
	if new_direction.num != Direction.NONE || !new_direction.equals(direction):
		direction = new_direction;


func _light_tick() -> bool:
	var lit := false;
	var shadowed := false;
	
	for beam in beamed_on_by.keys():
		if beam.btype == Beam.TYPE.LIGHT:
			lit = true;
		if beam.btype == Beam.TYPE.SHADOW:
			shadowed = true;
	
	in_the_shadow = shadowed && !lit;
	
	match [in_the_shadow && has_tag(TAGS.FLYING)]:
		[true, false]:
			tags.push_back(TAGS.FLYING);
		[false, true]:
			tags.erase(TAGS.FLYING);
	
	super._light_tick();
	return false;


func _process(delta: float) -> void:
	match [in_the_shadow, animation_state]:
		[true, var st] when st != FLY:
			animation_state = FLY;
			animated_sprite.play(&"fly");
		[false, var st] when st != WALK:
			animation_state = WALK;
			animated_sprite.play(&"walk");
	super._process(delta);
