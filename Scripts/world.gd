extends WorldEnvironment


@export var _footstep_dust: PackedScene
@export var _jump_dust: PackedScene
@export var _land_dust: PackedScene
var _dust: AnimatedSprite2D


func spawn(scene: PackedScene, spawn_position: Vector2 = Vector2.ZERO) -> Node:
	var instance: Node = scene.instantiate()
	add_child(instance)
	if instance is CanvasItem:
		instance.position = spawn_position
	return instance


func _spawn_jump_dust(character_position: Vector2, flipped: bool) -> void:
	_dust = spawn(_jump_dust, character_position)
	_dust.flip_h = flipped
	_dust.animation_finished.connect(_dust.queue_free)


func _spawn_land_dust(character_position: Vector2, flipped: bool) -> void:
	_dust = spawn(_land_dust, character_position)
	_dust.flip_h = flipped
	_dust.animation_finished.connect(_dust.queue_free)


func _spawn_footstep_dust(character_position: Vector2, flipped: bool) -> void:
	_dust = spawn(_footstep_dust, character_position)
	_dust.flip_h = flipped
	_dust.animation_finished.connect(_dust.queue_free)
