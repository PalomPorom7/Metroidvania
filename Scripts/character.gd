class_name Character extends CharacterBody2D


signal changed_direction(direction: float)
signal stepped(position: Vector2, flipped: bool)
signal jumped(position: Vector2, flipped: bool)
signal landed(position: Vector2, flipped: bool)


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var _footstep_sfx: AudioStreamPlayer2D = $Footstep
@onready var _jump_sfx: AudioStreamPlayer2D = $Jump
@onready var _land_sfx: AudioStreamPlayer2D = $Land


@export_category("Locomotion")
@export var _walk_speed: float = 256
@export var _run_speed: float = 512
@onready var _move_speed: float = _walk_speed
@export var _acceleration: float = 512
@export var _deceleration: float = 2048
var look_direction: float
var move_direction: float
var _is_facing_left: bool


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


func face_left(left: bool = true) -> void:
	if _animation.get_current_node() == "attack":
		return
	_sprite.scale.x = -1 if left else 1
	_is_facing_left = left
	changed_direction.emit(-1 if left else 1)


func walk() -> void:
	_move_speed = _walk_speed


func run() -> void:
	_move_speed = _run_speed


func jump() -> bool:
	if _is_on_floor or _coyote and not _coyote.is_stopped():
		velocity.y = _jump_force
		_jump_sfx.play_random()
		jumped.emit(position, _sprite.flip_h)
		is_jumping = true
		return true
	return false


func cancel_jump() -> void:
	if is_jumping:
		velocity.y /= 2


func attack() -> void:
	_animation.travel("attack")


func _ground_physics(delta: float) -> void:
	if move_direction:
		# acceleration from stand still or moving in the same move_direction
		if velocity.x == 0 or sign(velocity.x) == sign(move_direction):
			velocity.x = move_toward(velocity.x, move_direction * _move_speed, _acceleration * delta)
		# decelerate to turn around
		else:
			velocity.x = move_toward(velocity.x, move_direction * _move_speed, _deceleration * delta)
	# decelerate to stop
	else:
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)


func _air_physics(delta: float) -> void:
	# Add the gravity.
	velocity.y += _gravity * delta
	velocity.y = min(velocity.y, _terminal_velocity)
	# air control
	if move_direction:
		velocity.x = move_toward(velocity.x, move_direction * _move_speed, _acceleration * _air_control * delta)
	# air brakes
	else:
		velocity.x = move_toward(velocity.x, 0, _deceleration * _air_brakes * delta)


func _on_landed() -> void:
	_land_sfx.play_random()
	landed.emit(position, _sprite.flip_h)


func _on_stepped() -> void:
	stepped.emit(position, _sprite.flip_h)
	_footstep_sfx.play_random()


func _face_move_direction() -> void:
	if _is_facing_left and move_direction > 0:
		face_left(false)
	elif not _is_facing_left and move_direction < 0:
		face_left()


func _physics_process(delta: float) -> void:
	if _animation.get_current_node() == "attack":
		move_direction = 0
	_face_move_direction()
	# Check if the character walked off of a ledge or landed
	_was_on_floor = _is_on_floor
	_is_on_floor = is_on_floor()
	if _coyote and _was_on_floor and not _is_on_floor and velocity.y >= 0:
		_coyote.start()
		#print("Walked off of a ledge!")
	elif not _was_on_floor and _is_on_floor:
		_on_landed()
	if _is_on_floor:
		_ground_physics(delta)
	else:
		_air_physics(delta)

	# End jumps at apex
	if is_jumping and velocity.y >= 0:
		is_jumping = false

	move_and_slide()
