tool
extends Spatial

export(Vector3) var core_origin = Vector3.ZERO setget set_core_origin

export(float, 0, 10) var core_light_opening = 0.0 setget set_core_opening
export(float, 0, 10) var core_light_multiplier = 1.0

func _ready():
	set_core_opening(core_light_opening)

func set_core_opening(new_value: float):
	core_light_opening = new_value
	
	if is_inside_tree():
		$Core.material_override.next_pass.set_shader_param("grow", new_value)
		$Core/OmniLight.light_energy = new_value * core_light_multiplier

func set_core_origin(new_value: Vector3):
	core_origin = new_value
	
	if is_inside_tree():
		$Core.material_override.next_pass.set_shader_param("grow_origin", core_origin)
	
