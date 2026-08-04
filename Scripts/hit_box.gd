extends Area2D


@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _ray: RayCast2D = get_node_or_null("%RayCast2D")


func _on_area_entered(area: Area2D) -> void:
	if _ray:
		_ray.target_position = area.global_position - global_position
		_ray.force_raycast_update()
		if _ray.is_colliding() and not _ray.get_collider() == area:
			return
	if area.has_method("take_damage"):
		area.take_damage(1, (area.global_position - global_position).normalized())


func _on_character_changed_direction(direction: float) -> void:
	_shape.position.x = abs(_shape.position.x) * (-1 if direction < 0 else 1)
