extends Node2D


@onready var _map_viewport: SubViewport = %MapViewport
@onready var _fade: ColorRect = %Fade
@onready var _kitty: CharacterBody2D = %Kitty
@onready var _player: Timer = %Player
@onready var _camera: Camera2D = %Camera2D
@onready var _health_counter: HBoxContainer = %HealthCounter
var _current_room: Room


func _ready() -> void:
	get_viewport().canvas_cull_mask = 1
	_map_viewport.world_2d = get_viewport().world_2d
	_camera.follow(_kitty)
	_kitty.get_node("HurtBox").set_counter(_health_counter)


# TEST
	#_test()


#func _test() -> void:
	#var data: Data = Data.new()
	#data.max_health_upgrades = [true, false, true, false]
	#print(data.max_health_upgrades)


func on_player_entered_room(room_entered: Room) -> void:
	if room_entered == _current_room:
		return
	_player.disable()
	_kitty.process_mode = Node.PROCESS_MODE_DISABLED
	if _current_room:
		await _fade.to_black()
		_current_room.unload_contents()
	_current_room = room_entered
	_current_room.load_contents()
	_camera.set_bounds(_current_room.get_top_left(), _current_room.get_bottom_right())
	_kitty.process_mode = Node.PROCESS_MODE_INHERIT
	await _fade.to_clear()
	_player.enable()
