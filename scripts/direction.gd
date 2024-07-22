@tool
extends RefCounted
class_name Direction


enum {
	UP, DOWN, LEFT, RIGHT, NONE
}


var num : int = UP;
var vec : Vector2i :
	get:
		match num:
			UP:
				return Vector2i(0, -1);
			DOWN:
				return Vector2i(0, 1);
			LEFT:
				return Vector2i(-1, 0);
			RIGHT:
				return Vector2i(1, 0);
			_:
				return Vector2i(0, 0);


func equals(other: Direction) -> bool:
	return self.num == other.num;


static func from_num(num_v: int) -> Direction:
	var direction = Direction.new();
	direction.num = num_v;
	return direction;


static func from_vec(vec_v: Vector2) -> Direction:
	match Vector2i(vec_v.normalized()):
		Vector2i(0, -1):
			return Direction.from_num(UP);
		Vector2i(0, 1):
			return Direction.from_num(DOWN);
		Vector2i(1, 0):
			return Direction.from_num(RIGHT);
		Vector2i(-1, 0):
			return Direction.from_num(LEFT);
		_:
			return Direction.from_num(NONE);
