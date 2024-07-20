extends LevelObject
class_name AltaObject

var animated_sprite: AnimatedSprite2D = AnimatedSprite2D.new();


func _init():
	tags.push_back(TAGS.ALTA);
	tags.push_back(TAGS.PUSH);
	tags.push_back(TAGS.LIGHT);


func _ready():
	animated_sprite.position = self._starting_position;
	animated_sprite.centered = false;
	animated_sprite.sprite_frames = load("res://assets/alta_sprite_frames.tres");
	
	add_child(animated_sprite);


func place_on_level(starting_position: Vector2, level: GameLevel) -> void:
	position = starting_position;
	
	_starting_position = starting_position;
	_desired_position = starting_position;
	var diff =  level.cell_size - self.animated_sprite.sprite_frames\
		.get_frame_texture("walk", 0).get_size();
	animated_sprite.offset = Vector2(diff.x / 2., diff.y - margin_from_bottom);


func move_to(new_position: Vector2) -> void:
	var new_direction = Direction.from_vec(new_position - position);
	
	if new_direction.num == Direction.LEFT && direction.num != Direction.LEFT:
		animated_sprite.flip_h = true;
	if new_direction.num == Direction.RIGHT && direction.num != Direction.RIGHT:
		animated_sprite.flip_h = false;
	
	if new_direction.num != Direction.NONE || !new_direction.equals(direction):
		direction = new_direction;
	_movement_mode = _MOVE;
	_starting_position = position;
	_desired_position = new_position;
	
	_movement_progress = 0.;
