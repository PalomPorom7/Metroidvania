extends RayCast2D


signal ledge_detected(direction: int)


var _was_colliding: bool
var _is_colliding: bool


func _physics_process(_delta: float) -> void:
	_was_colliding = _is_colliding
	_is_colliding = is_colliding()
	if _was_colliding and not _is_colliding:
		ledge_detected.emit(sign(position.x))


func _on_enemy_changed_direction(direction: float) -> void:
	position.x = abs(position.x) * (-1 if direction < 0 else 1)
