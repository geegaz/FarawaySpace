@tool
class_name ShipEffects
extends Node

@export var core_trail_width: float = 0.0: set = set_core_trail_width
@export var wing_trails_emitting: bool = true: set = set_wing_trails_emitting
@export var dust_effect_emitting: bool = true: set = set_dust_effect_emitting

@export var core_trail: Trail3D
@export var wing_trails: Array[Trail3D]
@export var dust_effect: GPUParticles3D

func set_core_trail_width(new_value: float):
	core_trail_width = new_value
	
	if core_trail:
		core_trail.width = core_trail_width

func set_wing_trails_emitting(new_value: bool):
	wing_trails_emitting = new_value
	
	#var time_limit: = 0.25 if wing_trails_emitting else 0.0
	#for trail in wing_trails:
		#trail.time_limit = time_limit

func set_dust_effect_emitting(new_value: bool):
	dust_effect_emitting = new_value
	
	if dust_effect:
		dust_effect.emitting = dust_effect_emitting
