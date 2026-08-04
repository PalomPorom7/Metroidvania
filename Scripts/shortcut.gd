extends StaticBody2D


@export var _flag_name: String
var _damaged: bool


func _ready() -> void:
	if File.data.flags.has(_flag_name) and File.data.flags[_flag_name]:
		queue_free()


func _on_damage_received() -> void:
	$Shake.start()
	$GPUParticles2D.restart()
	if _damaged:
		destroy()
	else:
		_damaged = true
		$Brace.texture.region.position.x = 32
		await get_tree().create_timer(1).timeout
		$Shake.stop()


func _shake(intensity: float = 1) -> void:
	$Wall.offset = Vector2.RIGHT.rotated(randf_range(0, TAU)) * intensity


func _scatter_debris() -> void:
	$Debris.visible = true
	for piece: RigidBody2D in $Debris.get_children():
		piece.set_deferred("freeze", false)
		piece.call_deferred("apply_impulse", piece.position)


func destroy() -> void:
	File.data.flags[_flag_name] = true
	File.save_game()
	_scatter_debris()
	$Wall.visible = false
	$Brace.visible = false
	await $GPUParticles2D.finished
	queue_free()
