extends BossEncounter


func _decide_what_to_do_next() -> void:
	if _boss.is_dead:
		return
	_boss.face_left(_target.global_position.x < _boss.global_position.x)
	await get_tree().create_timer(randf() / _phase).timeout
	# Change behaviour based on phase:
	#match _phase:
		#1:
			#pass
		#2:
			#pass
	# Select next action
	if _boss.is_ready_to_charge:
		_boss.charge(sign(_target.global_position.x - _boss.global_position.x))
	else:
		match randi_range(0, 1):
			0:
				_boss.move_to_position(global_position.x + randi_range(-300, 300))
			1:
				_boss.shoot_fireballs(randi_range(_phase, _phase * 2))
