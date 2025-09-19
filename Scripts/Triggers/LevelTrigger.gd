class_name LevelTrigger
extends Trigger

export var level: Resource
export var portal_material: ShaderMaterial

onready var _PortalSphere: MeshInstance = $PortalSphere
onready var _PortalLight: OmniLight = $PortalLight

func _ready() -> void:
	if not level:
		return # Skip if no level was provided
	
	if portal_material and level.level_cubemap:
		# Make material unique
		var new_material: = portal_material.duplicate()
		new_material.set_shader_param("cubemap", level.level_cubemap)
		# Assign unique material to the portal
		_PortalSphere.material_override = new_material
	
	_PortalLight.light_color = level.level_color

func trigger_entered(ship: Ship)->void:
	SceneManager.change_level(level)

#func trigger_exited(ship: Ship)->void:
#	pass
