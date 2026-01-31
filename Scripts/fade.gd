extends ColorRect


const CLEAR: Color = Color(0, 0, 0, 0)
const DURATION: float = 1
var _tween: Tween


func _ready() -> void:
	visible = true


func to_black() -> Signal:
	return _tween_color(Color.BLACK)


func to_clear() -> Signal:
	return _tween_color(CLEAR)


func _tween_color(final_color: Color) -> Signal:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "color", final_color, DURATION)
	return _tween.finished
