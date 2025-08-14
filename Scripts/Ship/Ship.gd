class_name Ship
extends KinematicBody

signal started_moving
signal stopped_moving

# Movement exports
export var max_speed: float = 25 # m/s
export var acceleration: float = 10 # m/s/s
export var deceleration: float = 5 # m/s/s
export var forward_multiplier: float = 1.0
export var backward_multiplier: float = 0.5
export(float, 0, 1) var collision_correction_amount: float = 0.05
export var gravity_enabled: bool = true
export var gravity: float = 9.8
export var gravity_max_speed: float = 100.0
export var gravity_ray_length: float = 4.0
export(int, LAYERS_3D_PHYSICS) var gravity_ray_mask = 1
export(float, 0.0, 100.0) var spring_strength: float = 20.0
export(float, 0.0, 10.0) var spring_damping: float = 4.0
export(float, 0, 1) var gravity_correction_amount: float = 0.02

# Movement variables
var speed: float
var prev_speed: float
var speed_amount: float
var ground_distance: float
var gravity_speed: float

var velocity: Vector3

# Collision variables
var collision_correction: Vector2

# Visuals variables
var dir: float = 0.0
var power: float = 0.0
var tilt: float = 0.0

# Gameplay nodes
onready var _Camera: Camera = $Camera
onready var _ShipInput: ShipInput = $Input
# Visuals nodes
onready var _ShipEffects: ShipEffects = $Effects
onready var _Model: Spatial = $Model
onready var _AnimationTree: AnimationTree = $Model/AnimationTree
# Audio nodes
onready var _ShipAudio: AudioStreamPlayer3D = $Audio

onready var space_state: PhysicsDirectSpaceState = get_world().direct_space_state

func _ready() -> void:
	pass

func _process(delta):
	# Do all gameplay-related calculation that don't depend on physics
	
	# Ship rotation
	var target_turn = _ShipInput.turn_input + collision_correction
	if target_turn != Vector2.ZERO:
		rotation.y -= deg2rad(target_turn.x)
		rotation.x -= deg2rad(target_turn.y)
		rotation.x = clamp(rotation.x, deg2rad(-90), deg2rad(90))
		orthonormalize()
	
	# Movement calculations
	
	# DIR - The amount of movement forward or backward
	dir = _ShipInput.forward_input * forward_multiplier - _ShipInput.backward_input * backward_multiplier
	
	# SPEED - The length of the velocity applied each frame
	var target_speed: float = dir * max_speed
	var target_accel: float = acceleration if dir != 0 else deceleration
	prev_speed = speed
	speed += target_accel * delta * sign(target_speed - speed)
	speed_amount = speed / max_speed # for later
	
	# POWER - Smoothed version of dir
	# Framerate-independant lerping
	# https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	power = lerp(power, dir, 1.0 - pow(10, -delta))
	
	# TILT - Rotation of the ship on the forward axis when turning
	var target_tilt: float = _ShipInput.turn_input.x * 0.5
	tilt = lerp(tilt, target_tilt, 1.0 - pow(10, -delta))
	tilt = clamp(tilt, -deg2rad(90.0), deg2rad(90.0))
	
	# Movement signals
	if is_zero_approx(prev_speed) and not is_zero_approx(speed):
		emit_signal("started_moving")
	elif is_zero_approx(speed) and not is_zero_approx(prev_speed):
		emit_signal("stopped_moving")
	
	# Tilting
	_Model.rotation.z = tilt
	
	# Trails
	_ShipEffects.core_trail_width = max(power, 0.0) * 0.3
	_ShipEffects.wing_trails_emitting = speed_amount > 0.9;
	
	if gravity_enabled:
		_ShipEffects.dust_effect_emitting = (ground_distance < gravity_ray_length and abs(speed_amount) > 0.1)
		_ShipEffects.move_dust_effect(global_translation + Vector3.DOWN * ground_distance)
	else:
		_ShipEffects.dust_effect_emitting = false
	
	# Camera
	if _Camera:
		_Camera.fov = lerp(70, 100, speed / max_speed) # need signed speed amount
	
	# Audio
	_ShipAudio.pitch_scale = clamp(
		abs(power) + 0.1 + 
		abs(_ShipInput.turn_input.x) * 0.1 + 
		rotation.x * 0.2, 
		0.01, 4)
	_ShipAudio.unit_db = linear2db(abs(power) * 3.0)
	
	# Animation
	_AnimationTree.set("parameters/speed/blend_position", speed_amount)
	_AnimationTree.set("parameters/power/blend_position", power)
	
	Debug.write_to_screen("Ship", "Speed: %s"%speed)
	Debug.write_to_screen("Ship", "Speed Amount: %s"%speed_amount)


func _physics_process(delta):
	# Only do necessary physics calculations
	collision_correction = Vector2.ZERO
	velocity = -global_transform.basis.z * speed
	
	if gravity_enabled:
		gravity_speed = max(gravity_speed - gravity * delta, -gravity_max_speed)
		
		var cast_vector = Vector3.DOWN * gravity_ray_length
		var result: Dictionary = space_state.intersect_ray(
			global_translation, global_translation + cast_vector, [], gravity_ray_mask)
		if not result.empty():
			ground_distance = (result.position - global_translation).length()
			var ground_offset: float = gravity_ray_length - ground_distance
			gravity_speed += ((ground_offset * spring_strength) - (gravity_speed * spring_damping)) * delta
			collision_correction += calculate_correction(result.normal) * gravity_correction_amount * abs(speed_amount)
		else:
			ground_distance = gravity_ray_length
	else:
		gravity_speed = move_toward(gravity_speed, 0.0, gravity * delta)
	
	var final_velocity: Vector3 = velocity + Vector3.UP * gravity_speed
	velocity = move_and_slide(final_velocity, Vector3.UP, false, 4, PI)
	
	
	var slide_count: = get_slide_count()
	if slide_count > 0:
		# Get the collision normal
		var col_normal: Vector3
		for slide in slide_count:
			var col: KinematicCollision = get_slide_collision(0)
			col_normal += col.normal
		col_normal = col_normal.normalized()
		collision_correction += calculate_correction(col_normal) * collision_correction_amount * abs(speed_amount)
	
	Debug.draw_line(global_translation, global_translation - global_transform.basis.z * 10.0, Color.blue)


func calculate_correction(collison_normal: Vector3)->Vector2:
	# Calculate the correction angle
	
	# On flat surfaces the "ideal direction" is usually parallel to the surface, 
	# meaning the ship's forward vector follows a vector perpendicular
	# to the surface's normal.
	# We can do that by finding the angle between the local normal and its
	# "flattened" version (with its Z component removed, and so perpendicular 
	# to the local forward vector), and add it to the turning input later.
	var local_normal: Vector3 = global_transform.basis.xform_inv(collison_normal)
	var local_normal_flattened: = Vector3(local_normal.x, local_normal.y, 0.0).normalized()
	var plane_normal: = local_normal_flattened.cross(Vector3.FORWARD).normalized()
	
	var angle: = local_normal.signed_angle_to(local_normal_flattened, plane_normal)
	var correction = Vector2(
		rad2deg(angle) * local_normal_flattened.x, 
		-rad2deg(angle) * local_normal_flattened.y)
	
	Debug.draw_line(global_translation, global_translation + local_normal * 10.0, Color.green)
	Debug.draw_line(global_translation, global_translation + plane_normal * 10.0, Color.red)
	Debug.draw_line(global_translation, global_translation + local_normal_flattened * 10.0, Color.purple)
	
	return correction

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_switch_gravity"):
		gravity_enabled = !gravity_enabled
