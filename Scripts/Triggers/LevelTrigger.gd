class_name LevelTrigger
extends Trigger

@export var portal_data: LevelPortalData
@export_group("References")
@export var portal_sphere: MeshInstance3D
@export var portal_light: OmniLight3D

func _ready() -> void:
	if portal_data:
		portal_sphere.material_override.set_shader_parameter("cubemap", portal_data.cubemap)
		portal_light.light_color = portal_data.color

@warning_ignore("unused_parameter")
func trigger_entered(ship: Ship)->void:
	if portal_data:
		LevelManager.change_level(portal_data.level, portal_data.color)

@warning_ignore("unused_parameter")
func trigger_exited(ship: Ship)->void:
	pass
