extends Timer


@export var _direction: int = 1
@onready var _enemy: Character = get_parent()


func _process(_delta: float) -> void:
	if is_stopped():
		_enemy.move_direction = _direction
		if _enemy.is_on_wall():
			if _enemy.get_wall_normal().x < 0:
				_enemy.face_left(true)
			else:
				_enemy.face_left(false)
			_enemy.move_direction = 0
			_direction = sign(_enemy.get_wall_normal().x)
			start()
	else:
		_enemy.move_direction = 0
