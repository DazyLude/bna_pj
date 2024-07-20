extends RefCounted
class_name Direction


enum {
	UP, DOWN, LEFT, RIGHT
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


static func from_num(num: int) -> Direction:
	var direction = Direction.new();
	direction.num = num;
	return direction;
