extends Node2D


@export var _oscillation_range: float = 16
@export var _oscillation_speed: float = 1
@onready var _room = get_parent()
@onready var _region = _room.get_parent()
@onready var _area: Area2D = $Area2D
@onready var _initial_y_position: float = _area.position.y
@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
var t: float


func _process(delta: float) -> void:
	t = wrapf(t + delta * _oscillation_speed, 0, TAU)
	_area.position.y = _initial_y_position + sin(t) * _oscillation_range


func _on_body_entered(_body: Node2D) -> void:
	_sprite.play()
	File.data.last_saved_at = [_region.name, _room.name]
	File.save_game()
