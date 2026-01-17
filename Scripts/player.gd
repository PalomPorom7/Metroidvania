extends Timer


@export var character: CharacterBody2D
@onready var _camera: Camera2D = %Camera2D
var _buffered_input: Callable
var _is_enabled: bool


@onready var _look_hold: Timer = $LookHold
var _look_direction: float
var _is_looking: bool


func enable() -> void:
	_is_enabled = true
	if Input.is_action_pressed("run"):
		character.run()


func disable() -> void:
	_is_enabled = false
	character.direction = 0
	character.walk()


func _input(event: InputEvent) -> void:
	if not _is_enabled:
		return
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


func _on_look_hold_timeout() -> void:
	#print("Start looking")
	_camera.look(_look_direction)
	_is_looking = true


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not _is_enabled:
		return
	_look_direction = Input.get_axis("look_up", "look_down")
	# Stop looking and reset camera
	if _is_looking:
		if not _look_direction:
			#print("Stop looking")
			_camera.look(0)
			_is_looking = false
	# Started holding look direction input, so start timer
	elif _look_direction:
		if _look_hold.is_stopped():
			#print("Start timer")
			_look_hold.start()
	# Stopped holding look direction input before timer finished, so cancel timer
	elif not _look_hold.is_stopped():
		#print("Cancel timer")
		_look_hold.stop()
	character.look_direction = _look_direction
	character.move_direction = Input.get_axis("move_left", "move_right")
	if not is_stopped():
		if _buffered_input.call():
			stop()
			#print("buffered input succeeded")
		#else:
			#print("buffered input failed")
