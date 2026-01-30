extends Sprite2D


@export var _scroll_scale: Vector2
@export var _auto_scroll: Vector2
@onready var _original_position: Vector2 = position
@onready var _camera = get_viewport().get_camera_2d()


func _process(delta: float) -> void:
	position = _original_position + _camera.offset_from_midpoint() * _scroll_scale
	region_rect.position.x = wrapf(region_rect.position.x - _auto_scroll.x * delta, 0, region_rect.size.x)
	region_rect.position.y = wrapf(region_rect.position.y - _auto_scroll.y * delta, 0, region_rect.size.y)
