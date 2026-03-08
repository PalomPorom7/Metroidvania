class_name Data extends Resource


@export var max_health: int = 5
var current_health: int

@export var max_magic: float = 64.0
var current_magic: float


var name: String
var on_or_off: bool
var max_health_upgrades: Array[bool]
var group_of_related_information: Dictionary = {"key": "value"}
var coordinates: Vector2
var favourite_colour: Color
# var my_custom_resource: CustomResource


func _init() -> void:
	max_health = 5
	max_magic = 64.0
	max_health_upgrades.resize(4)
	group_of_related_information["something"] = false
