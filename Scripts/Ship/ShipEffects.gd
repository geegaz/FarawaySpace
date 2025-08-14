tool
class_name ShipEffects
extends Node

export(Vector3) var core_offset = Vector3.ZERO setget set_core_offset
export(float, 0, 10) var core_light_opening: float = 0.0 setget set_core_opening
export(float, 0, 10) var core_light_multiplier: float = 1.0

export(float, 0, 10) var core_trail_width: float = 0.0 setget set_core_trail_width
export var wing_trails_emitting: bool = true setget set_wing_trails_emitting
export var dust_effect_emitting: bool = true setget set_dust_effect_emitting

export(ShaderMaterial) var glowing_core_material

export var glowing_core_light: NodePath
onready var _GlowingCoreLight: OmniLight = get_node_or_null(glowing_core_light)

export var core_trail: NodePath
onready var _CoreTrail: Spatial = get_node_or_null(core_trail)

export var right_wing_trail: NodePath
onready var _RightWingTrail: Spatial = get_node_or_null(right_wing_trail)

export var left_wing_trail: NodePath
onready var _LeftWingTrail: Spatial = get_node_or_null(left_wing_trail)

export var dust_effect: NodePath
onready var _DustEffect: Particles = get_node_or_null(dust_effect)


func set_core_opening(new_value: float):
	core_light_opening = new_value
	
	if glowing_core_material:
		glowing_core_material.next_pass.set_shader_param("grow", new_value)
	if _GlowingCoreLight:
		_GlowingCoreLight.light_energy = new_value * core_light_multiplier

func set_core_offset(new_value: Vector3):
	core_offset = new_value
	
	if glowing_core_material:
		glowing_core_material.next_pass.set_shader_param("grow_origin", core_offset)

func set_core_trail_width(new_value: float):
	core_trail_width = new_value
	
	if _CoreTrail:
		_CoreTrail.material.set_shader_param("line_width", core_trail_width)

func set_wing_trails_emitting(new_value: bool):
	wing_trails_emitting = new_value
	
	if _RightWingTrail:
		_RightWingTrail.sampling_mode = _RightWingTrail.SamplingMode.Idle if new_value else _RightWingTrail.SamplingMode.None
	if _LeftWingTrail:
		_LeftWingTrail.sampling_mode = _LeftWingTrail.SamplingMode.Idle if new_value else _LeftWingTrail.SamplingMode.None

func set_dust_effect_emitting(new_value: bool):
	dust_effect_emitting = new_value
	
	if _DustEffect:
		_DustEffect.emitting = new_value
