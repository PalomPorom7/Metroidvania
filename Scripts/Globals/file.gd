extends Node


const PATH: String = "user://"
var file_name: String = "save.res"


var data: Data


func _ready() -> void:
	if ResourceLoader.exists(PATH + file_name):
		load_game()
	else:
		new_game()


func new_game() -> void:
	data = Data.new()


func save_game() -> void:
	ResourceSaver.save(data, PATH + file_name)


func load_game() -> void:
	data = ResourceLoader.load(PATH + file_name)
