extends Character


@export var _crawl_direction: int = 1
var _stuck_on_surface: Vector2
var _forward: Vector2
var _collision: KinematicCollision2D


func _process(_delta: float) -> void:
	move_direction = _crawl_direction


## TEST
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("look_down"):
		#unstick()


func _physics_process(delta: float) -> void:
	if _stuck_on_surface:
		_crawling_physics(delta)
	else:
		_collision = move_and_collide(velocity * delta, true) # will not actually move the character
		if _collision:
			_stuck_on_surface = _collision.get_normal().rotated(PI) # 180 degrees
		else:
			super._physics_process(delta)


func _crawling_physics(delta: float) -> void:
	_face_move_direction()
	_collision = move_and_collide(_stuck_on_surface * _gravity * delta)
	if _collision:
		_stuck_on_surface = _collision.get_normal().rotated(PI)
		_forward = _stuck_on_surface.rotated(PI/2 if _is_facing_left else -PI/2)
		rotation = _forward.angle() - (PI if _is_facing_left else 0.0)
		if move_direction:
			_collision = move_and_collide(_forward * _move_speed * delta)
			if _collision:
				_stuck_on_surface = _collision.get_normal().rotated(PI)
	else:
		unstick()


func unstick() -> void:
	_stuck_on_surface = Vector2.ZERO
	rotation = 0
