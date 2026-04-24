extends Character


@export var _fly_speed: float = 100
var _fly_direction: Vector2
var _is_flying: bool


func _physics_process(delta: float) -> void:
	if _is_flying:
		_flying_physics(delta)
		move_and_slide()
	else:
		super._physics_process(delta)


func _flying_physics(delta: float) -> void:
	# Face move_direction
	if _is_facing_left and _fly_direction.x > 0:
		face_left(false)
	elif not _is_facing_left and _fly_direction.x < 0:
		face_left()
	# Fly!
	if _fly_direction:
		velocity = velocity.move_toward(_fly_direction * _fly_speed, _acceleration * _air_control * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _deceleration * _air_brakes * delta)


func fly(direction: Vector2) -> void:
	_is_flying = true
	_fly_direction = direction


func stop_flying() -> void:
	_is_flying = false
	_fly_direction = Vector2.ZERO
