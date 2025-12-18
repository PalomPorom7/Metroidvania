extends CharacterBody2D


@export_category("Locomotion")
@export var _walk_speed: float = 256
@export var _run_speed: float = 512
@onready var _move_speed: float = _walk_speed
@export var _acceleration: float = 512
@export var _deceleration: float = 2048
var direction: float


@export_category("Jumping")
@export var _jump_height: float = 256
@export var _gravity_multiplier: float = 1
@export var _air_control: float = 0.5
@export var _air_brakes: float = 0.5
@export var _terminal_velocity: float = 2048
@onready var _coyote: Timer = get_node_or_null("Coyote")
@onready var _gravity: float = ProjectSettings.get("physics/2d/default_gravity") * _gravity_multiplier
@onready var _jump_force: float = sqrt(_gravity * _jump_height * 2) * -1
var _was_on_floor: bool
var _is_on_floor: bool
var is_jumping: bool


func walk() -> void:
	_move_speed = _walk_speed


func run() -> void:
	_move_speed = _run_speed


func jump() -> bool:
	if _is_on_floor or _coyote and not _coyote.is_stopped():
		#if _coyote and not _coyote.is_stopped():
			#print("Coyote jump successful!")
		velocity.y = _jump_force
		is_jumping = true
		return true
	return false


func cancel_jump() -> void:
	if is_jumping:
		velocity.y /= 2


func _ground_physics(delta: float) -> void:
	if direction:
		# acceleration from stand still or moving in the same direction
		if velocity.x == 0 or sign(velocity.x) == sign(direction):
			velocity.x = move_toward(velocity.x, direction * _move_speed, _acceleration * delta)
		# decelerate to turn around
		else:
			velocity.x = move_toward(velocity.x, direction * _move_speed, _deceleration * delta)
	# decelerate to stop
	else:
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)


func _air_physics(delta: float) -> void:
	# Add the gravity.
	velocity.y += _gravity * delta
	velocity.y = min(velocity.y, _terminal_velocity)
	# air control
	if direction:
		velocity.x = move_toward(velocity.x, direction * _move_speed, _acceleration * _air_control * delta)
	# air brakes
	else:
		velocity.x = move_toward(velocity.x, 0, _deceleration * _air_brakes * delta)


func _physics_process(delta: float) -> void:
	_was_on_floor = _is_on_floor
	_is_on_floor = is_on_floor()
	if _was_on_floor and not _is_on_floor and velocity.y >= 0:
		_coyote.start()
		#print("Walked off of a ledge!")
	if _is_on_floor:
		_ground_physics(delta)
	else:
		_air_physics(delta)

	# End jumps at apex
	if is_jumping and velocity.y >= 0:
		is_jumping = false

	move_and_slide()
