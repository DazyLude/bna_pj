extends Node
class_name Phrase

@export var text : String = "";
@export_enum("left", "right", "none") var side : int = 0;
@export var reaction : Node2D = null;
