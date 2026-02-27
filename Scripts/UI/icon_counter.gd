extends Control


@export var _icon_scene: PackedScene
@export var _cap: int = 9
@onready var _max_value: int = get_child_count()
var _value: int


func set_max_value(new_max_value: int) -> void:
	# Validate
	new_max_value = clampi(new_max_value, 0, _cap)
	if new_max_value == _max_value:
		return
	# Increase
	if new_max_value > _max_value:
		for i in range(_max_value, new_max_value):
			add_child(_icon_scene.instantiate())
	# Decrease
	else:
		for i in range(_max_value, new_max_value, -1):
			get_child(i - 1).queue_free()
	_max_value = new_max_value


func set_value(new_value: int) -> void:
	# Validate
	new_value = clampi(new_value, 0, _max_value)
	if new_value == _value:
		return
	# Increase
	if new_value > _value:
		for i in range(_value, new_value):
			get_child(i).fill()
	# Decrease
	else:
		for i in range(_value, new_value, -1):
			get_child(i - 1).empty()
	_value = new_value


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
				var number: int = event.keycode - KEY_0
				if Input.is_action_pressed("look_up"):
					print("Set max health to " + str(number))
					set_max_value(number)
				else:
					print("Set current health to " + str(number))
					set_value(number)
