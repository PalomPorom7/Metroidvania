extends BossEncounter


@export var _flaming_boulder_scene: PackedScene
var _new_flaming_boulder: RigidBody2D


func start() -> void:
	%Door.close()
	super.start()


func end() -> void:
	super.end()
	%Door.open()


func spawn_flaming_boulders() -> void:
	for i in randi_range(_phase, _phase * 2):
		_new_flaming_boulder = _flaming_boulder_scene.instantiate()
		add_child(_new_flaming_boulder)
		_new_flaming_boulder.position = Vector2(randi_range(-384, 384), -448)
		get_viewport().get_camera_2d().shake(2, 0.25)


func _decide_what_to_do_next() -> void:
	if _boss.is_dead:
		return
	_boss.face_left(_target.global_position.x < _boss.global_position.x)
	await get_tree().create_timer(randf() / _phase).timeout
	# Select next action
	if _boss.is_ready_to_charge:
		_boss.charge(sign(_target.global_position.x - _boss.global_position.x))
	else:
		match randi_range(0, 1):
			0:
				_boss.move_to_position(global_position.x + randi_range(-300, 300))
			1:
				_boss.shoot_fireballs(randi_range(_phase, _phase * 2))


func _on_garbage_collector_body_entered(body: Node2D) -> void:
	body.queue_free()
