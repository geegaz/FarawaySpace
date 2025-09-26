class_name LevelTrigger
extends Trigger

@export var level: LevelData
@export var portal_sphere: MeshInstance3D
@export var portal_light: OmniLight3D

func _ready() -> void:
	if not level:
		return # Skip if no level was provided
	
	if level.level_cubemap:
		portal_sphere.material_override.set_shader_parameter("cubemap", level.level_cubemap)
	portal_light.light_color = level.level_color

@warning_ignore("unused_parameter")
func trigger_entered(ship: Ship)->void:
	SceneManager.change_level(level)

@warning_ignore("unused_parameter")
func trigger_exited(ship: Ship)->void:
	pass
