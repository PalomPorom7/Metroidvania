extends Character


signal double_jumped(position: Vector2, flipped: bool)


# Local reference to the Save Data Resource's list of unlocked abilities
@onready var _abilities_unlocked: Array[bool] = File.data.abilities_unlocked
var _double_jump_is_ready: bool = true


func jump() -> bool:
	if _abilities_unlocked[Enums.Abilities.DOUBLE_JUMP] and _double_jump_is_ready and not _is_on_floor:
		# do the double jump here
		#print("Double Jumped!")
		velocity.y = _jump_force
		_jump_sfx.play_random()
		double_jumped.emit(position, _sprite.flip_h)
		_double_jump_is_ready = false
		is_jumping = true
		return true
	return super.jump()


func _on_landed() -> void:
	super._on_landed()
	if not _double_jump_is_ready:
		#print("Double Jump is ready!")
		_double_jump_is_ready = true
