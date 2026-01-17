extends Camera2D


var _subject: Node2D


func follow(subject: Node2D) -> void:
	_subject = subject


func _process(_delta: float) -> void:
	if _subject:
		position = _subject.global_position
