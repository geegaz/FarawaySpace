tool
class_name LevelData
extends Resource

export var level_name: String setget set_level_name
export(String, FILE, "*.tscn") var level_scene_path: String
export var level_cubemap: CubeMap
export var level_color: Color = Color.white

func set_level_name(value: String)->void:
	level_name = value
	resource_name = level_name
