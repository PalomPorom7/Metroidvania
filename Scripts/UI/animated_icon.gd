extends TextureRect


@onready var _animation: AnimationPlayer = $AnimationPlayer


func fill() -> void:
	_animation.play("fill")


func empty() -> void:
	_animation.play("empty")
