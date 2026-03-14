extends Area2D


signal max_health_changed(new_max_health: int)
signal current_health_changed(new_current_health: int)
signal died


var _max_health: int = 5
@onready var _current_health: int = _max_health


func initialize(max_health: int) -> void:
	_max_health = max_health
	_current_health = max_health
	max_health_changed.emit(_max_health)
	current_health_changed.emit(_current_health)


func set_counter(counter: Control) -> void:
	max_health_changed.connect(counter.set_max_value)
	current_health_changed.connect(counter.set_value)
	max_health_changed.emit(_max_health)
	current_health_changed.emit(_current_health)


func take_damage(amount: int) -> void:
	_current_health = max(_current_health - amount, 0)
	current_health_changed.emit(_current_health)
	if _current_health == 0:
		died.emit()


func recover(amount: int = 0) -> void:
	if not amount:
		_current_health = _max_health
	else:
		_current_health = min(_current_health + amount, _max_health)
	current_health_changed.emit(_current_health)


# TEST
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("look_up"):
		#recover(1)
	#elif event.is_action_pressed("look_down"):
		#take_damage(1)
	#elif event.is_action_pressed("jump"):
		#recover()
