extends Node

@export var default_level: String
@export var start_input_active: bool

func _ready() -> void:
	PlayerManager.player_input.enabled = start_input_active
	
	LevelManager.load_additive = true
	var start_level: = LevelManager.current_level
	if start_level.is_empty():
		start_level = default_level
	LevelManager.change_level(start_level)
