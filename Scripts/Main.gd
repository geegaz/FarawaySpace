extends Node

@export var default_level: String
@export var start_playing: bool

func _ready() -> void:
	PlayerManager.playing = start_playing
	
	LevelManager.load_additive = true
	var start_level: = LevelManager.curren_level_name
	if start_level.is_empty():
		start_level = default_level
	LevelManager.change_level(start_level)
