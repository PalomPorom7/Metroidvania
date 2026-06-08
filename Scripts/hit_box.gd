extends Area2D


@onready var _shape: CollisionShape2D = $CollisionShape2D


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)


func _on_character_changed_direction(direction: float) -> void:
	_shape.position.x = abs(_shape.position.x) * (-1 if direction < 0 else 1)
