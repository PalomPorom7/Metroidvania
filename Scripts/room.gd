class_name Room extends Area2D


@export var _contents_scene: PackedScene
@onready var _shape_node: CollisionShape2D = $CollisionShape2D
var _contents_node: Node2D


func load_contents() -> void:
	if not _contents_node:
		_contents_node = _contents_scene.instantiate()
		add_child(_contents_node)


func unload_contents() -> void:
	if _contents_node:
		_contents_node.queue_free()
		_contents_node = null


func get_top_left() -> Vector2:
	return _shape_node.global_position + _shape_node.shape.get_rect().position


func get_bottom_right() -> Vector2:
	return _shape_node.global_position + _shape_node.shape.get_rect().end


func _on_body_entered(_body: Node2D) -> void:
	load_contents()
	#print(_body)
