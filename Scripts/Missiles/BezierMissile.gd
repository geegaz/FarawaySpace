extends KinematicBody

signal hit(collision)

export var missile_noise: OpenSimplexNoise = preload("res://Scripts/Missiles/missile_noise.tres")
export var missile_noise_curve: Curve = preload("res://Scripts/Missiles/missile_noise_curve.tres")
export var missile_speed: float = 10.0
export(float, EASE) var missile_easing: float = 2.0

export var hit_effect: PackedScene

var start_tick: int
var duration: float
var start_position: Vector3
var start_handle: Vector3
var target: Spatial
var target_handle: Vector3

func _ready() -> void:
	start_tick = Time.get_ticks_msec()
	if target:
		target_handle = target.global_translation.direction_to(global_translation)
		start_handle = global_translation.direction_to(target.global_translation)

func _physics_process(delta: float) -> void:
	var current_tick := Time.get_ticks_msec()
	var elapsed: float = current_tick - start_tick
	var time := ease(elapsed / duration, missile_easing)
	
	var target_position: Vector3 = bezier_position(start_position, start_handle,target.global_translation, target_handle, time)
	var target_direction: Vector3 = global_translation.direction_to(target.global_translation)
	
	# TODO: more movement code with easing and noise
	
	var collision = move_and_collide(target_position - global_translation)
	if collision:
		emit_signal("hit", collision)
		
		# TODO: more collision response ?
		
		if hit_effect:
			var new_effect: Spatial = hit_effect.instance()
			add_child(new_effect)

static func bezier_position(a: Vector3, a_handle: Vector3, b:Vector3, b_handle:Vector3, delta: float)->Vector3:
	var inverse_delta = 1.0 - delta
	return (
		(inverse_delta * inverse_delta * inverse_delta)	* a +
		(3 * inverse_delta * inverse_delta * delta)		* a_handle +
		(3 * inverse_delta * delta * delta)				* b +
		(delta * delta * delta)							* b_handle
	)
	
