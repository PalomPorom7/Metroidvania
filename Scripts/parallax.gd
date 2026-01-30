extends Sprite2D


@export var _scroll_scale: Vector2
@onready var _original_position: Vector2 = position
@onready var _camera = get_viewport().get_camera_2d()


func _process(_delta: float) -> void:
	position = _original_position + _camera.offset_from_midpoint() * _scroll_scale
