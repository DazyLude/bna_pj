extends LevelObject
class_name Prism


var beamed_on_by : Dictionary = {};
var reflecting : Dictionary = {};
@export var horizontal_direction : int = 1;
@export var vertical_direction : int = 0;


func _get_emission_directions() -> Array:
	var result := []
	for dir_num in reflecting.keys():
		result.push_back(Direction.from_num(dir_num));
	return result;


func _init() -> void:
	tags.push_back(TAGS.BEAM_SENSITIVE);
	tags.push_back(TAGS.BEAM_EMITTER);
	tags.push_back(TAGS.BEAM_STOPPER);
	tags.push_back(TAGS.PUSH);
	emitter_type = Beam.TYPE.NONE;


func _got_beamed_on(beam: Beam) -> void:
	beamed_on_by[beam] = null;


func _not_being_beamed_on(beam: Beam) -> void:
	beamed_on_by.erase(beam);


func _light_tick() -> bool:
	reflecting.clear();
	var changes = false;
	for beam in beamed_on_by.keys() as Array[Beam]:
		match [beam.btype, beam.direction.num]:
			[var t, var d] when t != Beam.TYPE.SHADOW && d == vertical_direction:
				reflecting[horizontal_direction] = null;
			[var t, var d] when t != Beam.TYPE.SHADOW && d == horizontal_direction:
				reflecting[vertical_direction] = null;
	
	
	if reflecting.size() != 0:
		changes = emitter_type != Beam.TYPE.LIGHT;
		emitter_type = Beam.TYPE.LIGHT;
	else:
		changes = emitter_type != Beam.TYPE.NONE;
		emitter_type = Beam.TYPE.NONE;
	
	return changes;


func move_to(new_position: Vector2) -> void:
	var new_direction = Direction.from_vec(new_position - position);
	match new_direction.num:
		Direction.UP:
			vertical_direction = Direction.UP;
		Direction.DOWN:
			vertical_direction = Direction.DOWN;
		Direction.LEFT:
			horizontal_direction = Direction.RIGHT;
		Direction.RIGHT:
			horizontal_direction = Direction.LEFT;
	super.move_to(new_position);
