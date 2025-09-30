@tool
class_name LevelPortalData
extends Resource

@export var level: String: set = set_level
@export var cubemap: Cubemap
@export var color: Color = Color.WHITE

func set_level(value: String)->void:
	level = value
	resource_name = level

func _validate_property(property: Dictionary) -> void:
	if property.name == "level":
		var level_names: = ",".join(LevelManager.LEVELS.keys())
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = level_names
