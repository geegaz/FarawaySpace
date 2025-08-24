extends Node

export var debug_draw_enabled: bool = true
export var start_level: Resource

func _ready() -> void:
	DebugDraw.enabled = debug_draw_enabled
	
	SceneManager.load_additive = true
	SceneManager.change_level(start_level)
