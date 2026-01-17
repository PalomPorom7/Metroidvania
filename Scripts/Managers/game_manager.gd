extends Node2D


@onready var _kitty: CharacterBody2D = %Kitty
@onready var _player: Timer = %Player
@onready var _camera: Camera2D = %Camera2D


func _ready() -> void:
	_camera.follow(_kitty)
	_player.enable()
