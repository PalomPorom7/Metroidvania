class_name Projectile extends Area2D


@export var _speed: float = 256
@export var _default_damage: int = 1
@onready var _animation: AnimatedSprite2D = $AnimatedSprite2D
var _direction: Vector2
var _damage: int
var _is_moving: bool


func fire(direction: Vector2, damage: int = 0) -> void:
	_direction = direction
	_animation.flip_h = direction.x < 0
	_damage = damage if damage else _default_damage
	_is_moving = true


func _process(delta: float) -> void:
	if _is_moving:
		position += _direction * _speed * delta


func _on_impact() -> void:
	_is_moving = false
	collision_mask = 0
	_animation.play("impact")
	_animation.animation_finished.connect(queue_free)


# Colliding with hurt box
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(_damage, (area.global_position - global_position).normalized())
		_on_impact()


# Colliding with terrain
func _on_body_entered(_body: Node2D) -> void:
	_on_impact()
