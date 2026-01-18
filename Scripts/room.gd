extends Area2D


@onready var _shape_node: CollisionShape2D = $CollisionShape2D


func get_top_left() -> Vector2:
	return global_position + _shape_node.shape.get_rect().position


func get_bottom_right() -> Vector2:
	return global_position + _shape_node.shape.get_rect().end
