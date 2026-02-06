extends Control


@export var _pan_speed: float = 1024
@onready var _camera: Camera2D = %MapCamera
var _is_open: bool


func is_open() -> bool:
	return _is_open


func open() -> void:
	# do other things...
	# tween from off screen etc...
	show()
	_is_open = true


func close() -> void:
	hide()
	_is_open = false


func toggle() -> void:
	if _is_open:
		close()
	else:
		open()


func pan(direction: Vector2) -> void:
	_camera.offset += direction * _pan_speed * get_process_delta_time()
