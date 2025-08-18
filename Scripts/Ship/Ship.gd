class_name Ship
extends KinematicBody

signal started_moving
signal stopped_moving
signal gravity_changed(value)

# Movement exports
export var max_speed: float = 25.0 # m/s
export var acceleration: float = 10.0 # m/s/s
export var deceleration: float = 5.0 # m/s/s
export var forward_multiplier: float = 1.0
export var backward_multiplier: float = 0.5
export(float, 0, 1) var collision_correction_amount: float = 0.05
# Garvity exports
export var gravity_enabled: bool = true setget set_gravity_enabled
export var gravity: float = 9.8
export var gravity_max_speed: float = 50.0
export var ground_ray_length: float = 4.0
export(float, 0.0, 100.0) var spring_strength: float = 20.0
export(float, 0.0, 10.0) var spring_damping: float = 4.0
export(float, 0, 1) var ground_correction_amount: float = 0.025

# Movement variables
var speed: float
var prev_speed: float
var gravity_speed: float
var velocity: Vector3

# Collision variables
var collision_correction: Vector2
var ground_position: Vector3
var ground_normal: Vector3
var ground_distance: float

# Visuals variables
var dir: float = 0.0
var power: float = 0.0
var tilt: float = 0.0
var speed_amount: float

# Gameplay nodes
onready var _Camera: Camera = $Camera
onready var _ShipInput: ShipInput = $Input
onready var _ShipPivot: Spatial = $Pivot
onready var _ShipInterpolation: PhysInterp = $Pivot/Interpolation
onready var _GroundRayCast: RayCast = $GroundRayCast
# Visuals nodes
onready var _ShipModel: Spatial = $Pivot/Interpolation/Model
onready var _AnimationTree: AnimationTree = $Pivot/Interpolation/Model/AnimationTree
onready var _GroundEffects: Spatial = $Pivot/Interpolation/GroundEffects
onready var _ShipEffects: ShipEffects = $ShipEffects
# Audio nodes
onready var _ShipAudio: AudioStreamPlayer3D = $Pivot/Interpolation/Audio

onready var space_state: PhysicsDirectSpaceState = get_world().direct_space_state

func _ready() -> void:
	_GroundRayCast.cast_to = Vector3.DOWN * ground_ray_length
	connect("gravity_changed", self, "_on_gravity_changed")

func _process(delta):
	# Do all gameplay-related calculation that don't depend on physics
	
	# Ship rotation
	var target_turn = _ShipInput.turn_input + collision_correction
	if target_turn != Vector2.ZERO:
		rotate_pivot(target_turn)
	
	# Movement calculations
	
	# DIR - The amount of movement forward or backward
	dir = _ShipInput.forward_input * forward_multiplier - _ShipInput.backward_input * backward_multiplier
	
	# SPEED - The length of the velocity applied each frame
	var target_speed: float = dir * max_speed
	var target_accel: float = acceleration if dir != 0 else deceleration
	prev_speed = speed
	speed += target_accel * delta * sign(target_speed - speed)
	# Smoothed version of speed/max_speed
	speed_amount = lerp(speed_amount, speed / max_speed, 1.0 - pow(10, -delta))  # for later
	
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
	_ShipModel.rotation.z = tilt
	
	# Trails
	_ShipEffects.core_trail_width = max(power, 0.0) * 0.3
	_ShipEffects.wing_trails_emitting = speed_amount > 0.9;
	
	if gravity_enabled:
		_ShipEffects.dust_effect_emitting = (ground_distance < ground_ray_length and abs(speed_amount) > 0.2)
		_GroundEffects.translation = Vector3.DOWN * ground_distance # interpolated
	else:
		_ShipEffects.dust_effect_emitting = false
	
	# Camera
	if _Camera:
		_Camera.fov = lerp(70, 100, speed_amount) # need signed speed amount
	
	# Audio
	_ShipAudio.pitch_scale = clamp(
		abs(power) + 0.1 + 
		abs(_ShipInput.turn_input.x) * 0.1 + 
		rotation.x * 0.2, 
		0.01, 4)
	_ShipAudio.unit_db = linear2db(abs(power) * 3.0)
	
	# Animation
	_AnimationTree["parameters/flying/power/blend_position"] = power
	_AnimationTree["parameters/grounded/power/blend_position"] = power


func _physics_process(delta):
	# Only do necessary physics calculations
	var pivot_basis: Basis = get_pivot_basis()
	var forward: = -pivot_basis.z
	
	collision_correction = Vector2.ZERO
	velocity = forward * speed
	
	if gravity_enabled:
		# Gravity acceleration
		gravity_speed = max(gravity_speed - gravity * delta, -gravity_max_speed)
		
		if _GroundRayCast.is_colliding():
			ground_position = _GroundRayCast.get_collision_point()
			ground_normal = _GroundRayCast.get_collision_normal()
			ground_distance = ground_position.distance_to(global_translation)
			var ground_offset: float = ground_ray_length - ground_distance
			# Spring force when close to the ground
			gravity_speed += calculate_spring(ground_offset, spring_strength, spring_damping) * delta
			# Additional correction when close to the ground (to help stay horizontal)
			collision_correction += calculate_correction(ground_normal) * ground_correction_amount * abs(speed / max_speed)
		else:
			ground_position = global_translation + _GroundRayCast.cast_to
			ground_normal = Vector3.UP
			ground_distance = ground_ray_length
	else:
		gravity_speed = move_toward(gravity_speed, 0.0, gravity * delta)
	
	# Add the gravity to the velocity
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
		collision_correction += calculate_correction(col_normal) * collision_correction_amount * abs(speed / max_speed)
		Debug.draw_line(global_translation, global_translation + col_normal * 10.0, Color.red)
	
	Debug.draw_line(global_translation, global_translation + forward * 10.0, Color.blue)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_switch_gravity"):
		set_gravity_enabled(!gravity_enabled)


func calculate_correction(collison_normal: Vector3)->Vector2:
	# Calculate the correction angle
	
	# We want to align the ship's forward axis with an "ideal direction",
	# perpendicular to the surface's normal
	# We do that by finding the angle between the local normal and its
	# "flattened" version with its Z component removed (so perpendicular 
	# to the local forward vector), and add it to the player's turning input.
	var pivot_basis: Basis = get_pivot_basis()
	var local_normal: Vector3 = pivot_basis.xform_inv(collison_normal)
	var local_normal_flattened: = Vector3(local_normal.x, local_normal.y, 0.0).normalized()
	var plane_normal: = local_normal_flattened.cross(Vector3.FORWARD).normalized()
	
	var angle: = local_normal.signed_angle_to(local_normal_flattened, plane_normal)
	var correction = Vector2(
		rad2deg(angle) * local_normal_flattened.x, 
		-rad2deg(angle) * local_normal_flattened.y)
	
	return correction


func calculate_spring(offset: float, strength: float, damping: float)->float:
	return (offset * strength) - (gravity_speed * damping)


func rotate_pivot(turn: Vector2)->void:
	_ShipPivot.rotation.y -= deg2rad(turn.x)
	_ShipPivot.rotation.x -= deg2rad(turn.y)
	_ShipPivot.rotation.x = clamp(_ShipPivot.rotation.x, deg2rad(-90), deg2rad(90))
	_ShipPivot.orthonormalize()


func get_pivot_basis(global: bool = true)->Basis:
	if global:
		return _ShipPivot.global_transform.basis
	return _ShipPivot.transform.basis


# Teleport to a global position & rotation
func teleport(target_position: Vector3, target_rotation: Vector3)->void:
	global_translation = target_position
	_ShipPivot.global_rotation = target_rotation
	_ShipInterpolation.reset_interpolation()
	_Camera.reset_interpolation()


func set_gravity_enabled(new_value: bool)->void:
	gravity_enabled = new_value
	emit_signal("gravity_changed", new_value)

func _on_gravity_changed(value: bool)->void:
	if value:
		_AnimationTree["parameters/playback"].travel("grounded")
	else:
		_AnimationTree["parameters/playback"].travel("flying")
