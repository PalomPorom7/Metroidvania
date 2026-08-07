extends Node2D


@export var music: AudioStream
@onready var _title: Label = %Title
var _tween: Tween


func _ready() -> void:
	$Label.visible = File.data.map.has(name)


func discover() -> void:
	File.data.map[name] = {}
	File.save_game()
	$Label.visible = true
	reveal_map()
	reveal_title()


func reveal_map() -> void:
	for room in get_children():
		if room is Room:
			room.discover(false)


func reveal_title() -> void:
	_title.modulate.a = 0
	_title.visible = true
	_tween = create_tween()
	_tween.tween_property(_title, "modulate:a", 1, 1)
	await _tween.finished
	await get_tree().create_timer(1).timeout
	_tween = create_tween()
	_tween.tween_property(_title, "modulate:a", 0, 1)
	await _tween.finished
