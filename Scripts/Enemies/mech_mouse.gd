extends CharacterBody2D


signal finished


var is_dead: bool
var is_ready_to_charge: bool


func face_left(left: bool) -> void:
	if is_dead:
		return


func charge(direction: int) -> void:
	if is_dead:
		finished.emit()
		return
	print("charge!")
	await get_tree().create_timer(1).timeout
	finished.emit()


func move_to_position(x_position: int) -> void:
	if is_dead:
		finished.emit()
		return
	print("move to position: " + str(x_position))
	await get_tree().create_timer(1).timeout
	finished.emit()


func shoot_fireballs(number: int) -> void:
	if is_dead:
		finished.emit()
		return
	print("fire!")
	await get_tree().create_timer(1).timeout
	finished.emit()
