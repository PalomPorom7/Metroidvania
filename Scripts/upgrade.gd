extends Area2D


const BRIGHT_WHITE: Color = Color(255, 255, 255, 1)
@export var _ability: Enums.Abilities


func _ready() -> void:
	if File.data.abilities_unlocked[_ability]:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	set_deferred("monitoring", false)
	$Float.queue_free()
	body.process_mode = Node.PROCESS_MODE_DISABLED
	%ParticlesIn.emitting = true
	var _tween: Tween = create_tween()
	_tween.tween_property(self, "global_position", body.global_position + Vector2(0, -18), 3)
	_tween.parallel().tween_property(self, "modulate", BRIGHT_WHITE, 3)
	_tween.parallel().tween_property(body, "modulate", BRIGHT_WHITE, 3)
	await _tween.finished
	File.data.abilities_unlocked[_ability] = true
	File.save_game()
	%PowerupHalo.visible = false
	%AnimatedSprite2D.visible = false
	%ParticlesIn.emitting = false
	%ParticlesOut.emitting = true
	body.update_sprite_visibility()
	_tween = create_tween()
	_tween.tween_property(body, "modulate", Color.WHITE, 1)
	await _tween.finished
	body.process_mode = Node.PROCESS_MODE_INHERIT
	queue_free()
