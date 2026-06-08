extends Character


signal double_jumped(position: Vector2, flipped: bool)
signal wall_jumped(position: Vector2, flipped: bool)
signal max_magic_changed(new_max_magic: float)
signal current_magic_changed(new_current_magic: float)


# Local reference to the Save Data Resource's list of unlocked abilities
@onready var _abilities_unlocked: Array[bool] = File.data.abilities_unlocked
# NOTE: As more layers are added to the state machine, this will need to be updated!
#@onready var _animation: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]


var _double_jump_is_ready: bool = true


@export_category("Wall Jump")
@export var _wall_slide_gravity_multiplier: float = 0.1
## Negative x values will be away from the wall, positive Y values up
@export var _wall_jump_force_multiplier: Vector2 = Vector2(-1, 1)
@export var _wall_jump_air_control: float = 4
@onready var _default_air_control: float = _air_control
@onready var _wall_jump_air_control_override: Timer = %WallJump
var _is_wall_sliding: bool


@export_category("Dash")
@export var _dash_distance: float = 128
@onready var _dash_force: float = sqrt(_dash_distance * _deceleration * 2)
@onready var _default_gravity: float = _gravity
@onready var _dash_cooldown: Timer = %DashCooldown
@onready var _dash_cooldown_effect: AnimatedSprite2D = %DashCooldownEffect


@export_category("Cast")
@export var _projectile: PackedScene
@export var _magic_cost: float = 16
@onready var _projectile_spawn: Marker2D = %ProjectileSpawn

var _max_magic: float
var _current_magic: float


func _ready() -> void:
	_max_magic = File.data.max_magic
	_current_magic = _max_magic
	max_magic_changed.emit(_max_magic)
	current_magic_changed.emit(_current_magic)


func update_sprite_visibility() -> void:
	%Cloak.visible = _abilities_unlocked[Enums.Abilities.DOUBLE_JUMP]
	%Gem.visible = _abilities_unlocked[Enums.Abilities.SHOOT]
	if _abilities_unlocked[Enums.Abilities.HAT]:
		%Hat.visible = true
		$HurtBox.collision_layer &= ~8192


func jump() -> bool:
	# Wall Jump
	if (
		_abilities_unlocked[Enums.Abilities.WALL_JUMP] and
		(
			_is_wall_sliding or
			not _is_on_floor and is_on_wall() and sign(move_direction * -1) == sign(get_wall_normal().x)
		)
	):
		velocity = Vector2(get_wall_normal().x, 1) * _jump_force * _wall_jump_force_multiplier
		_air_control = _wall_jump_air_control
		_wall_jump_air_control_override.start()
		_jump_sfx.play_random()
		wall_jumped.emit(position, _sprite.flip_h)
		_is_wall_sliding = false
		is_jumping = true
		return true
	# Double Jump
	elif _abilities_unlocked[Enums.Abilities.DOUBLE_JUMP] and _double_jump_is_ready and not _is_on_floor:
		velocity.y = _jump_force
		_jump_sfx.play_random()
		double_jumped.emit(position, _sprite.flip_h)
		_double_jump_is_ready = false
		is_jumping = true
		return true
	return super.jump()


func dash(direction: float) -> bool:
	if _abilities_unlocked[Enums.Abilities.DASH] and _animation.get_current_node() == "Movement" and _dash_cooldown.is_stopped():
		# Dash away from the wall
		if _is_wall_sliding:
			direction = sign(get_wall_normal().x)
		# Dash in the given direction
		elif direction:
			direction = sign(direction)
		# Dash forward
		else:
			direction = -1 if _is_facing_left else 1
		move_direction = direction
		velocity = Vector2(direction * _dash_force, 0)
		_gravity = 0
		_animation.travel("dash")
		return true
	return false


# MUST be called after dashing even if animation was interrupted!
func end_dash() -> void:
	_gravity = _default_gravity
	_dash_cooldown.start()
	_dash_cooldown_effect.stop()
	_dash_cooldown_effect.play()


func attack() -> bool:
	if _animation.get_current_node() == "Movement":
		_animation.travel("attack_1")
		return true
	elif _animation.get_current_node() == "attack_1":
		_animation.travel("attack_2")
		return true
	return false


func cast() -> bool:
	if _abilities_unlocked[Enums.Abilities.SHOOT] and _animation.get_current_node() == "Movement" and _current_magic >= _magic_cost:
		_animation.travel("cast")
		return true
	return false


func shoot_projectile() -> void:
	if _current_magic < _magic_cost:
		return
	_current_magic -= _magic_cost
	current_magic_changed.emit(_current_magic)
	var new_projectile: Area2D = _projectile.instantiate()
	get_parent().add_child(new_projectile)
	new_projectile.position = _projectile_spawn.global_position
	new_projectile.fire(Vector2.LEFT if _is_facing_left else Vector2.RIGHT)


func _on_wall_jump_air_control_override_timeout() -> void:
	_air_control = _default_air_control


func _physics_process(delta: float) -> void:
	if _animation.get_current_node() != "Movement":
		move_direction = 0
	super._physics_process(delta)


func _air_physics(delta: float) -> void:
	# Is the character currently wall sliding?
	if _is_wall_sliding:
		# End wall slide
		if not is_on_wall() or sign(get_wall_normal().x) == sign(move_direction):
			#print("Ended wall slide no longer touching a wall")
			_is_wall_sliding = false
		# Continue wall slide
		else:
			velocity.y += _gravity * _wall_slide_gravity_multiplier * delta
	# Start wall slide
	elif (
		_abilities_unlocked[Enums.Abilities.WALL_JUMP] and
		is_on_wall() and
		velocity.y >= 0 and
		# Player is pressing direction toward the wall
		sign(move_direction * -1) == sign(get_wall_normal().x)
	):
		#print("Start wall slide")
		velocity.y = min(velocity.y, 0)
		_is_wall_sliding = true
	else:
		# Any other time
		super._air_physics(delta)


func _on_landed() -> void:
	super._on_landed()
	# End a wall slide
	if _is_wall_sliding:
		#print("Ended wall slide by touching the floor")
		_is_wall_sliding = false
	# Restore the double jump after landing on the ground
	if not _double_jump_is_ready:
		_double_jump_is_ready = true
