extends AudioStreamPlayer2D


@export var _jump_effort: Array[AudioStream]


func _randomize_pitch() -> void:
	pitch_scale = randf_range(0.5, 1.5)


func play_jump_effort() -> void:
	if not playing and randf() < 0.25:
		_randomize_pitch()
		stream = _jump_effort[randi_range(0, _jump_effort.size() - 1)]
		play()
