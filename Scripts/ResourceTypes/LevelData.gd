@tool
class_name LevelData
extends Resource

@export var level_name: String: set = set_level_name
@export var level_scene_path: String # (String, FILE, "*.tscn")
@export var level_cubemap: Cubemap
@export var level_color: Color = Color.WHITE

func set_level_name(value: String)->void:
	level_name = value
	resource_name = level_name
