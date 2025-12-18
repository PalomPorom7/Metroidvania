extends Timer


@export var character: CharacterBody2D
var _buffered_input: Callable

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if not character.jump():
			_buffered_input = character.jump
			start()
			#print("start input buffer")
	elif event.is_action_released("jump"):
		character.cancel_jump()
	if event.is_action_pressed("run"):
		character.run()
	elif event.is_action_released("run"):
		character.walk()


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	character.direction = Input.get_axis("move_left", "move_right")
	if not is_stopped():
		if _buffered_input.call():
			stop()
			#print("buffered input succeeded")
		#else:
			#print("buffered input failed")
