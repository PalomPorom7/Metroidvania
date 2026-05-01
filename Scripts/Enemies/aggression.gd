extends Timer


@export var _attack_range: Vector2 = Vector2(32, 64)
@onready var _enemy: Character = get_parent()
var _target: Node2D
var _direction_to_target: Vector2
var _distance_to_target: float


func _process(_delta: float) -> void:
	if not _target:
		return
	_direction_to_target = _target.global_position - _enemy.global_position
	_distance_to_target = _direction_to_target.length()
	if _distance_to_target > _attack_range.y:
		_enemy.move_direction = sign(_direction_to_target.x)
		stop()
	elif _distance_to_target < _attack_range.x:
		_enemy.move_direction = sign(_direction_to_target.x) * -1
	else:
		_enemy.move_direction = 0
		_enemy.face_left(_direction_to_target.x < 0)
		if is_stopped():
			start()


func _on_timeout() -> void:
	_enemy.face_left(_direction_to_target.x < 0)
	_enemy.attack()


func resume(target: Node2D) -> void:
	_target = target
	process_mode = Node.PROCESS_MODE_INHERIT
	_enemy.run()


func pause() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
