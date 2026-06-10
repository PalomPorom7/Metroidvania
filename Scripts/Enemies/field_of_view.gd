extends Area2D


signal target_acquired(target: Node2D)
signal target_lost


@onready var _polygon: CollisionPolygon2D = %CollisionPolygon2D
@onready var _line_of_sight: RayCast2D = %LineofSight
var _target: Node2D
var _is_targeting: bool
var _is_in_field_of_view: bool
var _is_in_line_of_sight: bool


func _physics_process(_delta: float) -> void:
	if not _target:
		return
	_line_of_sight.target_position = _target.global_position - global_position
	_is_in_line_of_sight = _line_of_sight.get_collider() == _target
	if not _is_targeting and _is_in_field_of_view and _is_in_line_of_sight:
		_is_targeting = true
		target_acquired.emit(_target)
		#print("target acquired")
	elif _is_targeting and not _is_in_field_of_view and not _is_in_line_of_sight:
		_is_targeting = false
		target_lost.emit()
		_target = null
		#print("target lost")


func _on_body_entered(body: Node2D) -> void:
	_target = body
	_is_in_field_of_view = true


func _on_body_exited(_body: Node2D) -> void:
	_is_in_field_of_view = false


func _on_enemy_changed_direction(direction: float) -> void:
	var vertices: PackedVector2Array = _polygon.polygon
	for i in vertices.size():
		vertices[i].x = abs(vertices[i].x) * (-1 if direction < 0 else 1)
	_polygon.polygon = vertices
