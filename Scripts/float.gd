extends Node


@export var _oscillation_range: float = 16
@export var _oscillation_speed: float = 1


@onready var _parent: Node2D = get_parent()
@onready var _initial_y_position: float = _parent.position.y
var t: float


func _process(delta: float) -> void:
	t = wrapf(t + delta * _oscillation_speed, 0, TAU)
	_parent.position.y = _initial_y_position + sin(t) * _oscillation_range
