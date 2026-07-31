extends Node2D


@onready var _room = get_parent()
@onready var _region = _room.get_parent()
@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D


func _on_body_entered(_body: Node2D) -> void:
	_sprite.play()
	File.data.last_saved_at = [_region.name, _room.name]
	File.save_game()
