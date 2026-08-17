extends StaticBody2D


@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D

var _tween: Tween


func open() -> void:
	return _tween_position(-144)


func close() -> Signal:
	return _tween_position(-48)


func _tween_position(final_y_position: float) -> Signal:
	_collision.position.y = final_y_position
	if _tween:
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_sprite, "position:y", final_y_position, 0.5)
	return _tween.finished
