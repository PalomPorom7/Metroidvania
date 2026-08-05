class_name Data extends Resource


@export var last_saved_at: Array[String] # EX: ["Forest", "SaveRoom"]


@export var max_health: int = 5
var current_health: int

@export var max_magic: float = 64.0
var current_magic: float


@export var abilities_unlocked: Array[bool]
@export var flags: Dictionary[String, bool]
@export var map: Dictionary[String, Dictionary] # EX: ["Forest"]["SaveRoom"] = true



func _init() -> void:
	max_health = 5
	max_magic = 64.0
	abilities_unlocked.resize(Enums.Abilities.size())
