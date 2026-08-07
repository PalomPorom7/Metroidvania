class_name Room extends Area2D


signal room_entered(room: Room)


@export var _contents_scene: PackedScene
@onready var _shape_node: CollisionShape2D = $CollisionShape2D
@onready var _map: TileMapLayer = $TileMapLayer
@onready var _region: String = get_parent().name
var _contents_node: Node2D


func _ready() -> void:
	room_entered.connect($/root/Game.on_player_entered_room)
	area_exited.connect(_on_area_exited)
	body_entered.connect(_on_body_entered)
	update_map_visibility()


func update_map_visibility() -> void:
	# Player has never entered this region before
	if not File.data.map.has(_region):
		_map.visible = false
		return
	# Player does not know that this room exists
	if not File.data.map[_region].has(name):
		_map.visible = false
		return
	_map.visible = true
	# Player has entered this room before
	if File.data.map[_region][name]:
		_map.modulate.a = 1
	# Player has not entered this room before
	else:
		_map.modulate.a = 0.5


func discover(entered: bool) -> void:
	if not File.data.map.has(_region):
		get_parent().discover()
	if File.data.map[_region].has(name):
		File.data.map[_region][name] = File.data.map[_region][name] or entered
	else:
		File.data.map[_region][name] = entered
	update_map_visibility()


func load_contents() -> void:
	BGMusic.play_track(get_parent().music)
	if not _contents_node:
		_contents_node = _contents_scene.instantiate()
		add_child(_contents_node)


func unload_contents() -> void:
	if _contents_node:
		_contents_node.queue_free()
		_contents_node = null


func get_top_left() -> Vector2:
	return _shape_node.global_position + _shape_node.shape.get_rect().position


func get_bottom_right() -> Vector2:
	return _shape_node.global_position + _shape_node.shape.get_rect().end


func _on_area_exited(area: Node2D) -> void:
	if area is Projectile:
		area.queue_free()


func _on_body_entered(_body: Node2D) -> void:
	room_entered.emit(self)
	#load_contents()
	#print(_body)
