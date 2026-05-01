extends Timer


@export var _direction: int = 1
@onready var _enemy: Character = get_parent()
var _wall_normal_x: int


func _process(_delta: float) -> void:
	if is_stopped():
		_enemy.move_direction = _direction
		if _enemy.is_on_wall():
			_wall_normal_x = sign(_enemy.get_wall_normal().x)
			if _direction != _wall_normal_x:
				if _wall_normal_x < 0:
					_enemy.face_left(true)
				else:
					_enemy.face_left(false)
				wait_and_turn_around(_wall_normal_x * -1)
	else:
		_enemy.move_direction = 0


func wait_and_turn_around(direction: int) -> void:
	_enemy.move_direction = 0
	_direction = direction * -1
	start()


func pause() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func resume() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	_enemy.walk()
