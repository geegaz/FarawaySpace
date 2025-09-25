class_name LevelTrigger
extends Trigger

export var level: Resource

onready var _PortalSphere: MeshInstance = $PortalSphere
onready var _PortalLight: OmniLight = $PortalLight

func _ready() -> void:
	if not level:
		return # Skip if no level was provided
	
	if level.level_cubemap:
		_PortalSphere.material_override.set_shader_param("cubemap", level.level_cubemap)
	_PortalLight.light_color = level.level_color

func trigger_entered(ship: Ship)->void:
	SceneManager.change_level(level)

#func trigger_exited(ship: Ship)->void:
#	pass
