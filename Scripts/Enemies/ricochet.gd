extends Node


@export var _fly_direction: Vector2 = Vector2.ONE
@onready var _enemy: Character = get_parent()


func _ready() -> void:
	_fly_direction = _fly_direction.normalized()


func _process(_delta: float) -> void:
	if _enemy.is_on_wall():
		_fly_direction.x = abs(_fly_direction.x) * sign(_enemy.get_wall_normal().x)
	if _enemy.is_on_ceiling():
		_fly_direction.y = abs(_fly_direction.y)
	if _enemy.is_on_floor():
		_fly_direction.y = abs(_fly_direction.y) * -1
	_enemy.fly(_fly_direction)
