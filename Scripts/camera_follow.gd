extends Camera2D


@onready var _default_offset: Vector2 = offset
var _subject: Node2D


@export var _look_ahead_trans: Tween.TransitionType
@export var _look_ahead_ease: Tween.EaseType
@export var _look_ahead_duration: float = 1
var _look_ahead_tween: Tween


@export var _maximum_look_distance: float = 128
@export var _look_up_down_trans: Tween.TransitionType
@export var _look_up_down_ease: Tween.EaseType
@export var _look_up_down_duration: float = 1
var _look_up_down_tween: Tween


func follow(subject: Node2D) -> void:
	# Already following subject, so no change
	if subject == _subject:
		return
	# Stop reacting to the previous subject changing direction if it was a character
	if _subject and _subject is Character and _subject.changed_direction.is_connected(_on_subject_changed_direction):
		_subject.changed_direction.disconnect(_on_subject_changed_direction)
	# Follow the new subject
	_subject = subject
	# React to subject changing direction if it is a Character
	if _subject and _subject is Character:
		_subject.changed_direction.connect(_on_subject_changed_direction)


func look(direction: float) -> void:
	if _look_up_down_tween:
		_look_up_down_tween.kill()
	_look_up_down_tween = create_tween().set_trans(_look_up_down_trans).set_ease(_look_up_down_ease)
	_look_up_down_tween.tween_property(self, "offset:y", _maximum_look_distance * sign(direction) if direction else _default_offset.y, _look_up_down_duration)


func _on_subject_changed_direction(direction: float) -> void:
	if _look_ahead_tween:
		_look_ahead_tween.kill()
	_look_ahead_tween = create_tween().set_trans(_look_ahead_trans).set_ease(_look_ahead_ease)
	_look_ahead_tween.tween_property(self, "offset:x", _default_offset.x * sign(direction), _look_ahead_duration)


func _process(_delta: float) -> void:
	if _subject:
		position = _subject.global_position
