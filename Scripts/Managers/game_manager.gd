extends Node2D


signal ability_unlocked(ability: int)


@onready var _map_viewport: SubViewport = %MapViewport
@onready var _fade: ColorRect = %Fade
@onready var _kitty: CharacterBody2D = %Kitty
@onready var _player: Timer = %Player
@onready var _camera: Camera2D = %Camera2D
@onready var _health_counter: HBoxContainer = %HealthCounter
var _current_room: Room
var _kitty_hurt_box: Area2D


func _ready() -> void:
	get_viewport().canvas_cull_mask = 1
	_map_viewport.world_2d = get_viewport().world_2d
	_camera.follow(_kitty)
	_kitty_hurt_box = _kitty.get_node("HurtBox")
	_kitty_hurt_box.initialize(File.data.max_health)
	_kitty_hurt_box.set_counter(_health_counter)
	_kitty.update_sprite_visibility()
	_position_player_character()


func _position_player_character() -> bool:
	if File.data.last_saved_at:
		var region: Node2D = $WorldEnvironment.get_node(File.data.last_saved_at[0])
		var room: Room = region.get_node(File.data.last_saved_at[1])
		_kitty.global_position = room.get_node("SavePoint").global_position
		return room == _current_room
	else:
		_kitty.global_position = Vector2.ZERO
		return false


func unlock_ability(ability: int) -> void:
	File.data.abilities_unlocked[ability] = true
	ability_unlocked.emit(ability)


func on_player_entered_room(room_entered: Room) -> void:
	if room_entered == _current_room:
		return
	_player.disable()
	_kitty.process_mode = Node.PROCESS_MODE_DISABLED
	if _current_room:
		await _fade.to_black()
		_current_room.unload_contents()
	_current_room = room_entered
	_current_room.call_deferred("load_contents")
	_current_room.discover(true)
	_camera.set_bounds(_current_room.get_top_left(), _current_room.get_bottom_right())
	_kitty.process_mode = Node.PROCESS_MODE_INHERIT
	await _fade.to_clear()
	_player.enable()


func _on_player_died() -> void:
	_player.disable()
	# Wait 1 second
	await get_tree().create_timer(1).timeout
	var tween: Tween = create_tween()
	tween.tween_property(%GameOver, "modulate:a", 1, 1)
	await _fade.to_black()
	# Reposition the player character
	var same_room: bool = _position_player_character()
	tween = create_tween()
	tween.tween_property(%GameOver, "modulate:a", 0, 0.5)
	await tween.finished
	_kitty.revive()
	tween = create_tween()
	tween.tween_property(%Revive, "modulate:a", 1, 0.5)
	if same_room:
		await _fade.to_clear()
	else:
		await get_tree().create_timer(1).timeout
	tween = create_tween()
	tween.tween_property(%Revive, "modulate:a", 0, 0.5)
	_player.enable()
