class_name Ship
extends KinematicBody

signal started_moving
signal stopped_moving

# Movement variables
export var max_speed: float = 25 # m/s
export var acceleration: float = 10 # m/s/s
export var deceleration: float = 5 # m/s/s
export var forward_multiplier: float = 1.0
export var backward_multiplier: float = 0.5
export(float, 0, 1) var collision_correction_amount: float = 0.05

# Input variables
var turn_input: Vector2
var forward_input: float
var backward_input: float

# Movement variables
var speed: float = 0.0
var velocity: Vector3

# Collision variables
var collision_correction: Vector2

# Visuals variables
var dir: float = 0.0
var power: float = 0.0
var tilt: float = 0.0

# Gameplay nodes
onready var _Camera: Camera = get_viewport().get_camera()
# Visuals nodes
onready var _AnimTree: AnimationTree = $ShipVisuals/AnimationTree
onready var _Visuals: Spatial = $ShipVisuals
onready var _CoreTrail: Spatial = $ShipVisuals/Core/Trail3D
onready var _WingTrails: Array = [
	$ShipVisuals/RightWing/Trail3D,
	$ShipVisuals/LeftWing/Trail3D
]
# Audio nodes
onready var _Audio: AudioStreamPlayer3D = $ShipAudio

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# If the ship is being powered
	power = lerp(power, dir, 1 - exp(-4 * delta))
	var speed_amount = speed / max_speed
	
	var target_turn = turn_input + collision_correction
	if target_turn != Vector2.ZERO:
		rotation.y -= deg2rad(target_turn.x)
		rotation.x -= deg2rad(target_turn.y)
		rotation.x = clamp(rotation.x, deg2rad(-90), deg2rad(90))
		orthonormalize()
	
	# Visual rotation
	var target_tilt: float = turn_input.x * 0.5
	# Framerate-independant lerping
	# https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	tilt = lerp(tilt, target_tilt, 1.0 - pow(10, -delta))
	tilt = clamp(tilt, -deg2rad(90.0), deg2rad(90.0))
	_Visuals.rotation.z = tilt
	
	# Trails
	var core_trail_width = max(power, 0.0) * 0.3
	_CoreTrail.material.set_shader_param("line_width", core_trail_width)
	var trail_emitting: bool = speed_amount > 0.9;
	for trail in _WingTrails:
		if trail_emitting:
			trail.sampling_mode = trail.SamplingMode.Idle
		else:
			trail.sampling_mode = trail.SamplingMode.None
	
	# Camera
	if _Camera:
		_Camera.fov = lerp(70, 100, speed_amount)
	#Screenshake.set_shake(abs(power) * speed_amount * 0.2)
	
	# Audio
	_Audio.pitch_scale = clamp(
		abs(power) + 0.1 + 
		abs(turn_input.x) * 0.1 + 
		rotation.x * 0.2, 
		0.01, 4)
	_Audio.unit_db = linear2db(abs(power) * 3)
	
	# Animation
	_AnimTree.set("parameters/speed/blend_position", speed_amount)
	_AnimTree.set("parameters/power/blend_position", power)
	
	Debug.write_to_screen("Ship", "Speed: %s"%speed)
	Debug.write_to_screen("Ship", "Speed Amount: %s"%speed_amount)


func _physics_process(delta):
	var prev_speed = speed
	
	# Movement calculations
	dir = forward_input * forward_multiplier - backward_input * backward_multiplier
	var target_speed: float = dir * max_speed
	var target_accel: float = acceleration if dir != 0 else deceleration
	speed += target_accel * delta * sign(target_speed - speed)
	
	velocity = -global_transform.basis.z * speed
	velocity = move_and_slide(velocity, Vector3.UP, false, 4, PI)
	
	Debug.draw_line(global_translation, global_translation - global_transform.basis.z * 10.0, Color.blue)
	
	collision_correction = Vector2.ZERO
	var slide_count: = get_slide_count()
	if slide_count > 0:
		# Get the collision normal
		var col_normal: Vector3
		for slide in slide_count:
			var col: KinematicCollision = get_slide_collision(0)
			col_normal += col.normal
		col_normal = col_normal.normalized()
		
		# Calculate the correction angle:
		# On flat surfaces the "ideal direction" is usually parallel to the surface, 
		# meaning the ship's forward vector follows a vector perpendicular
		# to the surface's normal.
		# We can do that by finding the angle between the local normal and its
		# "flattened" version (with its Z component removed, and so perpendicular 
		# to the local forward vector), and add it to the turning input later.
		var local_normal: Vector3 = global_transform.basis.xform_inv(col_normal)
		var local_normal_flattened: = Vector3(local_normal.x, local_normal.y, 0.0).normalized()
		var plane_normal: = local_normal_flattened.cross(Vector3.FORWARD).normalized()
		
		var angle: = local_normal.signed_angle_to(local_normal_flattened, plane_normal)
		collision_correction = Vector2(
			rad2deg(angle) * local_normal_flattened.x, 
			-rad2deg(angle) * local_normal_flattened.y)
		collision_correction *= collision_correction_amount
		
		Debug.draw_line(global_translation, global_translation + local_normal * 10.0, Color.green)
		Debug.draw_line(global_translation, global_translation + plane_normal * 10.0, Color.red)
		Debug.draw_line(global_translation, global_translation + local_normal_flattened * 10.0, Color.purple)
	
	# Movement signals
	if is_zero_approx(prev_speed) and not is_zero_approx(speed):
		emit_signal("started_moving")
	elif is_zero_approx(speed) and not is_zero_approx(prev_speed):
		emit_signal("stopped_moving")
