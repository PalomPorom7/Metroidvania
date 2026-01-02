extends AudioStreamPlayer2D


@export var _sounds: Array[AudioStream]


func play_random() -> void:
	pitch_scale = randf_range(0.5, 1.5)
	if _sounds.size():
		stream = _sounds[randi_range(0, _sounds.size() - 1)]
	play()
