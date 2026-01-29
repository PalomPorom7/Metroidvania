extends Node2D


@onready var _kitty: CharacterBody2D = %Kitty
@onready var _player: Timer = %Player
@onready var _camera: Camera2D = %Camera2D
var _current_room: Room


func _ready() -> void:
	_camera.follow(_kitty)
	_player.enable()


func on_player_entered_room(room_entered: Room) -> void:
	if room_entered == _current_room:
		return
	if _current_room:
		_current_room.unload_contents()
	_current_room = room_entered
	_current_room.load_contents()
	_camera.set_bounds(_current_room.get_top_left(), _current_room.get_bottom_right())
