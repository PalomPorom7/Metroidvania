class_name Music extends AudioStreamPlayer


var _region_music: AudioStream
var _tween: Tween


func _ready() -> void:
	bus = "Music"


func play_track(track: AudioStream) -> void:
	if playing:
		if track == stream:
			return
		await stop_playing()
	stream = track
	play()
	_fade_volume(1)


func stop_playing() -> Signal:
	await _fade_volume(0)
	stop()
	return _tween.finished


func override_music(new_track: AudioStream) -> void:
	_region_music = stream
	play_track(new_track)


func revert_music() -> void:
	play_track(_region_music)


func _fade_volume(final_volume: float) -> Signal:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "volume_linear", final_volume, 1)
	return _tween.finished
