extends CharacterBody2D


# Signals for starting the boss fight, ending it, or phase transitions
signal engine_started
signal armor_damaged
signal died

# Flip things that need to be flipped
signal changed_direction(direction: int)

# Asynchronous movement signals
signal arrived
signal crashed

# Current action is complete, decide what to do next
signal finished


# The boss's body, which I will need to reference often so it will rumble up and down.
@onready var _body: Node2D = %Body

# Is this boss alive or dead?
var is_dead: bool

# Has the engine been started yet?
var _engine_is_started: bool
# How fast is the windup key spinning?
var _key_speed: float = 0.125
var _key_tween: Tween


# Spin the windup key when it is attacked
func _on_key_attacked() -> void:
	# The key can't die
	%KeyHurtBox.recover()
	# Start at double speed, then tween down to normal speed
	%Key.speed_scale = _key_speed * 2
	if _key_tween:
		_key_tween.kill()
	_key_tween = create_tween()
	_key_tween.tween_property(%Key, "speed_scale", _key_speed, 1)
	# Trigger a charge attack or start the engine
	if _engine_is_started:
		is_ready_to_charge = true
	else:
		_key_speed *= 2
		if _key_speed >= 1:
			_start_engine()


# After the windup key is attacked 3 times, start the battle
func _start_engine() -> void:
	%Gears.play()
	%Rumble.start()
	_engine_is_started = true
	engine_started.emit()


# Randomly move the body up and down at 12 FPS
func _on_rumble_timeout() -> void:
	_body.position.y = randi_range(-1, 1)


# All the visual components that need to flip left/right
@onready var _flip: Node2D = %Flip
# This boss is facing left by default
var _is_facing_left: bool = true


# Similar face left function as the character script
func face_left(left: bool) -> void:
	if is_dead:
		return
	_flip.scale.x = 1 if left else -1
	_is_facing_left = left
	changed_direction.emit(-1 if left else 1)


# Basic Locomotion variables
@export var _drive_speed: float = 256
@export var _charge_speed: float = 512
@export var _acceleration: float = 1024
@export var _deceleration: float = 2048
var _move_direction: int
var _is_driving: bool
var _is_charging: bool
var _destination: float
var _distance: float
@onready var _gravity: float = ProjectSettings.get("physics/2d/default_gravity")
# Driving speed is the default
@onready var _move_speed: float = _drive_speed
# An array holding both wheels, but could be any number of wheels
@onready var _wheels: Array[AnimatedSprite2D] = [%FrontWheel, %RearWheel]
# Is the boss wound up and ready to charge?
var is_ready_to_charge: bool
# Count the number of times this boss has crashed into a wall
var _crashes: int


# The boss is told to move to a specific x coordinate within the boss arena
func move_to_position(x_position: int) -> void:
	if is_dead:
		finished.emit()
		return
	_destination = x_position
	_move_direction = sign(_destination - global_position.x)
	_move_speed = _drive_speed
	_is_driving = true
	# Spin the wheels forward or backward depending on which direction they are facing and moving
	_spin_wheels(1 if _is_facing_left and _move_direction < 0 or not _is_facing_left and _move_direction > 0 else -1)
	await arrived
	finished.emit()


# The boss is told to charge forward until it crashes into a wall
func charge(direction: int) -> void:
	is_ready_to_charge = false
	if is_dead:
		finished.emit()
		return
	if not direction:
		direction = -1 if _is_facing_left else 1
	# Face the direction of the charge, and spin the wheels at double speed
	face_left(direction < 0)
	_spin_wheels(2)
	# Brief pause to telegraph the attack
	await get_tree().create_timer(0.5).timeout
	_move_direction = direction
	_move_speed = _charge_speed
	# Turn on the hit box to deal damage
	%HitBox.monitoring = true
	_is_charging = true
	await crashed
	# Another pause to stun the boss after crashing
	await get_tree().create_timer(0.5).timeout
	finished.emit()


# Synchronize all wheels with the same animation speed and turn on/off particle emitters
func _spin_wheels(direction: float) -> void:
	for wheel in _wheels:
		wheel.play("default", abs(direction), direction < 0)
		wheel.get_node("Rocks").emitting = direction != 0
		wheel.get_node("Dust").emitting = direction != 0


# Physics to move when driving or charging, plus gravity
func _physics_process(delta: float) -> void:
	if is_dead:
		_move_direction = 0
	if _move_direction:
		velocity.x = move_toward(velocity.x, _move_speed * _move_direction, _acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)
	if not is_on_floor():
		velocity.y += _gravity * delta
	move_and_slide()
	if _is_driving:
		_check_if_arrived_at_destination()
	if _is_charging and is_on_wall():
		_crash()


# Need to check if the boss is close enough to their destination that they should start to decelerate
func _check_if_arrived_at_destination() -> void:
	_distance = abs(_destination - global_position.x)
	# This is the same as the jump height formula, only reversed
	if _distance < pow(velocity.x, 2) / _deceleration / 2:
		_spin_wheels(0)
		_move_direction = 0
		_is_driving = false
		arrived.emit()


# Called when the boss charges and crashes into a wall
func _crash() -> void:
	_spin_wheels(0)
	# Bounce off of the wall
	velocity.x = _charge_speed * sign(get_wall_normal().x)
	# Turn off the hit box
	%HitBox.monitoring = false
	_is_charging = false
	# Count the number of crashes, and damage the armor plating on the third crash
	_crashes += 1
	if _crashes == 3:
		_damage_armor()
	crashed.emit()


# Phase 2 transition, becomes unstable and vulnerable to attacks
func _damage_armor() -> void:
	_key_speed = 2
	%Armor.texture.region.position.x = 256
	%Gears.speed_scale = 2
	%Key.speed_scale = 2
	%Rumble.wait_time = 1.0/24.0
	%HurtBox.monitorable = true
	armor_damaged.emit()


# Everything needed to shoot fireballs
@export var _fireball_scene: PackedScene
@onready var _barrel: Sprite2D = %Barrel
@onready var _fireball_spawn: Marker2D = %FireBallSpawn
var _barrel_tween: Tween
var _new_fireball: Projectile


# The boss is told to shoot a number of fireballs forward
func shoot_fireballs(number: int) -> void:
	if is_dead:
		finished.emit()
		return
	# Extend the barrel
	await _move_barrel(-16)
	# Shoot staggered fireballs
	for i in number:
		await get_tree().create_timer(0.25).timeout
		_shoot_fireball()
	# Retract the barrel
	await _move_barrel(0)
	finished.emit()


# Extend or retract the barrel
func _move_barrel(final_offset: float) -> Signal:
	if _barrel_tween:
		_barrel_tween.kill()
	_barrel_tween = create_tween()
	_barrel_tween.tween_property(_barrel, "offset:x", final_offset, 0.25)
	return _barrel_tween.finished


# Shoot a single fireball forward
func _shoot_fireball() -> void:
	_new_fireball = _fireball_scene.instantiate()
	get_parent().add_child(_new_fireball)
	_new_fireball.global_position = _fireball_spawn.global_position
	_new_fireball.fire(Vector2.LEFT if _is_facing_left else Vector2.RIGHT)


# When the boss's health reaches zero, turn off all colliders and stop all the animations
func _die() -> void:
	is_dead = true
	%HitBox.set_deferred("monitoring", false)
	%HurtBox.set_deferred("monitorable", false)
	%KeyHurtBox.set_deferred("monitorable", false)
	%Key.stop()
	%Gears.stop()
	%Rumble.stop()
	_spin_wheels(0)
	died.emit()
