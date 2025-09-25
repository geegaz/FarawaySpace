extends Node

@export var start_level: Resource
@export var start_input_active: bool

func _ready() -> void:
	PlayerManager.player_input.enabled = start_input_active
	
	SceneManager.load_additive = true
	SceneManager.change_level(start_level)
