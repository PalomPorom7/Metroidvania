extends Character


signal double_jumped(position: Vector2, flipped: bool)


# Local reference to the Save Data Resource's list of unlocked abilities
@onready var _abilities_unlocked: Array[bool] = File.data.abilities_unlocked
var _double_jump_is_ready: bool = true


@export var _wall_slide_gravity_multiplier: float = 0.1
var _is_wall_sliding: bool


func jump() -> bool:
	# Double Jump
	if _abilities_unlocked[Enums.Abilities.DOUBLE_JUMP] and _double_jump_is_ready and not _is_on_floor:
		velocity.y = _jump_force
		_jump_sfx.play_random()
		double_jumped.emit(position, _sprite.flip_h)
		_double_jump_is_ready = false
		is_jumping = true
		return true
	return super.jump()


func _air_physics(delta: float) -> void:
	# Is the character currently wall sliding?
	if _is_wall_sliding:
		# End wall slide
		if not is_on_wall() or sign(get_wall_normal().x) == sign(move_direction):
			print("Ended wall slide no longer touching a wall")
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
