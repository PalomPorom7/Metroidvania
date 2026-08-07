class_name BossEncounter extends Area2D


@export var _music: AudioStream
@export var _boss: CharacterBody2D
var _target: Node2D
var _phase: int


func start() -> void:
	BGMusic.override_music(_music)
	_phase = 1
	_decide_what_to_do_next()


func end() -> void:
	BGMusic.revert_music()


func set_phase(phase: int) -> void:
	_phase = phase


func _decide_what_to_do_next() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	set_deferred("monitoring", false)
	# Close the arena
	# Do any initialization
	_target = body
	#start()
