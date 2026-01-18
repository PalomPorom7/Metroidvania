extends Node2D


@onready var _kitty: CharacterBody2D = %Kitty
@onready var _player: Timer = %Player
@onready var _camera: Camera2D = %Camera2D
@onready var _current_level: Area2D = $WorldEnvironment/CurrentLevel


func _ready() -> void:
	_camera.set_bounds(_current_level.get_top_left(), _current_level.get_bottom_right())
	_camera.follow(_kitty)
	_player.enable()
