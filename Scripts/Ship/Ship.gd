class_name Ship
extends CharacterBody3D

signal started_moving
signal stopped_moving
signal gravity_changed(value)

@export var enabled: bool = true: set = set_enabled
# Movement exports
@export var max_speed: float = 25.0 # m/s
@export var acceleration: float = 10.0 # m/s/s
@export var deceleration: float = 5.0 # m/s/s
@export var forward_multiplier: float = 1.0
@export var backward_multiplier: float = 0.5
@export var collision_correction_amount: float = 0.05 # (float, 0, 1)
# Garvity exports
@export var gravity_enabled: bool = true: set = set_gravity_enabled
@export var gravity: float = 9.8
@export var gravity_max_speed: float = 50.0
@export var ground_ray_length: float = 4.0
@export var spring_strength: float = 20.0 # (float, 0.0, 100.0)
@export var spring_damping: float = 4.0 # (float, 0.0, 10.0)
@export var ground_correction_amount: float = 0.025 # (float, 0, 1)

# Input variables
var forward_input: float
var backward_input: float
var turn_input: Vector2

# Movement variables
var speed: float
var prev_speed: float
var gravity_speed: float
var velocity: Vector3

# Visuals variables
var dir: float = 0.0
var power: float = 0.0
var tilt: float = 0.0
var speed_amount: float

# Collision variables
var collision_correction: Vector2
var ground_position: Vector3
var ground_normal: Vector3
var ground_distance: float

# Gameplay nodes
@onready var _Camera: Camera3D = $Camera3D
@onready var _ShipPivot: Node3D = $Pivot
@onready var _ShipInterpolation: PhysInterp = $Pivot/Interpolation
@onready var _GroundRayCast: RayCast3D = $GroundRayCast
# Visuals nodes
@onready var _ShipModel: Node3D = $Pivot/Interpolation/Model
@onready var _AnimationTree: AnimationTree = $Pivot/Interpolation/Model/AnimationTree
@onready var _GroundEffects: Node3D = $Pivot/Interpolation/GroundEffects
@onready var _ShipEffects: ShipEffects = $ShipEffects
# Audio nodes
@onready var _ShipAudio: AudioStreamPlayer3D = $Pivot/Interpolation/Audio


func _enter_tree() -> void:
	PlayerManager.player = self
	connect("gravity_changed", Callable(self, "_on_gravity_changed"))

func _exit_tree() -> void:
#	if PlayerManager.player == self:
	PlayerManager.player = null

func _ready() -> void:
	set_gravity_enabled(gravity_enabled)
	_GroundRayCast.target_position = Vector3.DOWN * ground_ray_length

func _process(delta):
	# Do all gameplay-related calculation that don't depend on physics
	
	# Ship rotation
	var target_turn = turn_input + collision_correction
	if target_turn != Vector2.ZERO:
		rotate_pivot(target_turn)
	
	# Movement calculations
	
	# DIR - The amount of movement forward or backward
	dir = forward_input * forward_multiplier - backward_input * backward_multiplier
	
	# SPEED - The length of the velocity applied each frame
	var target_speed: float = dir * max_speed
	var target_accel: float = acceleration if dir != 0 else deceleration
	prev_speed = speed
	speed += target_accel * delta * sign(target_speed - speed)
	# Smoothed version of speed/max_speed
	speed_amount = lerp(speed_amount, speed / max_speed, 1.0 - pow(10, -delta))  # for later
	
	# GRAVITY SPEED - The length of the downward velocity applied by gravity
	if gravity_enabled:
		# Gravity acceleration
		gravity_speed = max(gravity_speed - gravity * delta, -gravity_max_speed)
	else:
		gravity_speed = move_toward(gravity_speed, 0.0, gravity * delta)
	
	# POWER - Smoothed version of dir
	# Framerate-independant lerping
	# https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	power = lerp(power, dir, 1.0 - pow(10, -delta))
	
	# TILT - Rotation of the ship on the forward axis when turning
	var target_tilt: float = turn_input.x * 0.5
	tilt = lerp(tilt, target_tilt, 1.0 - pow(10, -delta))
	tilt = clamp(tilt, -deg_to_rad(90.0), deg_to_rad(90.0))
	
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
		_GroundEffects.position = Vector3.DOWN * ground_distance # interpolated
	else:
		_ShipEffects.dust_effect_emitting = false
	
	# Camera
	if _Camera:
		_Camera.fov = lerp(70, 100, speed_amount) # need signed speed amount
	
	# Audio
	_ShipAudio.pitch_scale = clamp(
		abs(power) + 0.1 + 
		abs(turn_input.x) * 0.1 + 
		rotation.x * 0.2, 
		0.01, 4)
	_ShipAudio.volume_db = linear_to_db(abs(power) * 3.0)
	
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
		if _GroundRayCast.is_colliding():
			ground_position = _GroundRayCast.get_collision_point()
			ground_normal = _GroundRayCast.get_collision_normal()
			ground_distance = ground_position.distance_to(global_position)
			var ground_offset: float = ground_ray_length - ground_distance
			# Spring force when close to the ground
			gravity_speed += calculate_spring(ground_offset, spring_strength, spring_damping) * delta
			# Additional correction when close to the ground (to help stay horizontal)
			collision_correction += calculate_correction(ground_normal) * (
				ground_correction_amount * pow(abs(speed / max_speed), 2.0))
			
			DebugDraw.draw_point(ground_position, Color.RED, 1.0)
		else:
			ground_position = global_position + _GroundRayCast.target_position
			ground_normal = Vector3.UP
			ground_distance = ground_ray_length
	
	# Add the gravity to the velocity
	var final_velocity: Vector3 = velocity + Vector3.UP * gravity_speed
	set_velocity(final_velocity)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(4)
	set_floor_max_angle(PI)
	move_and_slide()
	velocity = velocity
	
	var slide_count: = get_slide_collision_count()
	if slide_count > 0:
		# Get the collision normal
		var col_normal: Vector3 = Vector3.ZERO
		for slide in slide_count:
			var col: KinematicCollision3D = get_slide_collision(0)
			col_normal += col.normal
		col_normal = col_normal.normalized()
		collision_correction += calculate_correction(col_normal) * (
			collision_correction_amount * pow(abs(speed / max_speed), 2.0))
		DebugDraw.draw_line(global_position, global_position + col_normal * 10.0, Color.RED)
	
	DebugDraw.draw_line(global_position, global_position + forward * 10.0, Color.BLUE)


func calculate_correction(collison_normal: Vector3)->Vector2:
	# Calculate the correction angle
	
	# We want to align the ship's forward axis with an "ideal direction",
	# perpendicular to the surface's normal
	# We do that by finding the angle between the local normal and its
	# "flattened" version with its Z component removed (so perpendicular 
	# to the local forward vector), and add it to the player's turning input.
	var pivot_basis: Basis = get_pivot_basis()
	var local_normal: Vector3 = (collison_normal) * pivot_basis
	var local_normal_flattened: = Vector3(local_normal.x, local_normal.y, 0.0).normalized()
	var plane_normal: = local_normal_flattened.cross(Vector3.FORWARD).normalized()
	
	var angle: = local_normal.signed_angle_to(local_normal_flattened, plane_normal)
	var correction = Vector2(
		rad_to_deg(angle) * local_normal_flattened.x, 
		-rad_to_deg(angle) * local_normal_flattened.y)
	
	return correction


func calculate_spring(offset: float, strength: float, damping: float)->float:
	return (offset * strength) - (gravity_speed * damping)


func rotate_pivot(turn: Vector2)->void:
	_ShipPivot.rotation.y -= deg_to_rad(turn.x)
	_ShipPivot.rotation.x -= deg_to_rad(turn.y)
	_ShipPivot.rotation.x = clamp(_ShipPivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	_ShipPivot.orthonormalize()


func get_pivot_basis(global: bool = true)->Basis:
	if global:
		return _ShipPivot.global_transform.basis
	return _ShipPivot.transform.basis


# Teleport to a global position & rotation
func teleport(target_position: Vector3, target_rotation: Vector3)->void:
	global_position = target_position
	_ShipPivot.global_rotation = target_rotation
	_ShipInterpolation.reset_interpolation()
	_Camera.reset_interpolation()


func set_enabled(value: bool)->void:
	enabled = value
	forward_input = 0.0
	backward_input = 0.0
	turn_input = Vector2.ZERO
	speed = 0.0
	gravity_speed = 0.0
	set_physics_process(value)

func set_gravity_enabled(new_value: bool)->void:
	gravity_enabled = new_value
	emit_signal("gravity_changed", new_value)


func _on_gravity_changed(value: bool)->void:
	if value:
		_AnimationTree["parameters/playback"].travel("grounded")
	else:
		_AnimationTree["parameters/playback"].travel("flying")
