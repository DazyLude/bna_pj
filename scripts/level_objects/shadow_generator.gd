extends LevelObject
class_name ShadowGenerator


func _init() -> void:
	tags.append(TAGS.BEAM_SENSITIVE);
	tags.append(TAGS.BEAM_EMITTER);
	tags.append(TAGS.BEAM_STOPPER);
	emitter_type = Beam.TYPE.NONE;


func _got_beamed_on(beam: Beam) -> void:
	emitter_type = Beam.TYPE.SHADOW;


func _stopped_being_beamed_on() -> void:
	emitter_type = Beam.TYPE.NONE;
