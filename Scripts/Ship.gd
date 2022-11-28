extends KinematicBody

signal started_moving
signal stopped_moving

# Movement variables
export var max_speed: float = 25 # m/s
export var acceleration: float = 10 # m/s/s
export var deceleration: float = 5 # m/s/s
export var forward_multiplier: float = 1.0
export var backward_multiplier: float = 0.5

# Rotation variables
export(Vector2) var mouse_sensitivity: Vector2 = Vector2(0.1, 0.1)
export(Vector2) var controller_sensitivity: Vector2 = Vector2(2.0, 2.0)
export(bool) var mouse_invert_y: bool = true
var last_rotation: Vector3 = Vector3.ZERO

export var targeting_system: NodePath
export var missiles_system: NodePath

var dir: float = 0.0
var power: float = 0.0
var speed: float = 0.0
var speed_amount: float
var velocity: Vector3

var target_index: int = 0

# Gameplay
onready var _Camera: Camera = get_viewport().get_camera()
onready var _TargetingSystem: Node = get_node(targeting_system)
onready var _MissilesSystem: Node = get_node(missiles_system)
# Visuals
onready var _AnimTree: AnimationTree = $ShipVisuals/AnimationTree
onready var _Visuals: Spatial = $ShipVisuals
onready var _CoreTrail: Spatial = $ShipVisuals/Core/Trail3D
onready var _WingTrails: Array = [
	$ShipVisuals/RightWing/Trail3D,
	$ShipVisuals/LeftWing/Trail3D
]
# SFX
onready var _Audio: AudioStreamPlayer3D = $ShipAudio

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# If the ship is being powered
	power = lerp(power, dir, 1 - exp(-4 * delta))
	speed_amount = speed / max_speed
	
	###### Cosmetic effects ######
	
	# Visual rotation
	var rotation_speed := rotation - last_rotation
	var tilt: float = clamp(-rotation_speed.y * 20, -PI/2, PI/2)
	# Framerate-independant lerping
	# https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	_Visuals.rotation.z = lerp(_Visuals.rotation.z, tilt, 1 - exp(-4 * delta))
	last_rotation = rotation
	
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
	_Camera.fov = lerp(70, 100, speed_amount)
	var shake_amount: float = abs(power) * speed_amount * 0.2
	Screenshake.set_shake(shake_amount)
	#Input.start_joy_vibration(0, shake_amount, 0.0, 0.1)
	
	# Audio
	_Audio.pitch_scale = clamp(
		abs(power) + 0.1 + 
		abs(rotation_speed.y) * 1.2 + 
		rotation.x * 0.2, 
		0.01, 4)
	_Audio.unit_db = linear2db(abs(power) * 3)
	
	# Animation
	_AnimTree.set("parameters/speed/blend_position", speed_amount)
	_AnimTree.set("parameters/power/blend_position", power)


func _physics_process(delta):
	var prev_speed = speed
	
	# Input management
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * controller_sensitivity
	vector_rotate(input_dir)
	
	# Movement calculations
	accel_movement(delta)
	velocity = move_and_slide(velocity)
	
	# Movement signals
	if is_zero_approx(prev_speed) and not is_zero_approx(speed):
		emit_signal("started_moving")
	elif is_zero_approx(speed) and not is_zero_approx(prev_speed):
		emit_signal("stopped_moving")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var rot: Vector2 = event.relative * mouse_sensitivity
		if mouse_invert_y:
			rot.y *= -1
		vector_rotate(rot)
	
	if event.is_action_pressed("action_shoot"):
		var target: Spatial = null
		if _TargetingSystem: 
			var targets: Array = _TargetingSystem.get_visible_targets()
			var size: = targets.size()
			if size > 0:
				target_index = (target_index + 1) % size
				target = targets[target_index]
		if _MissilesSystem:
			_MissilesSystem.fire_missile(target)


func accel_movement(delta: float):
	# dir goes from -0.5 to 2
	dir = (
		Input.get_action_strength("move_front") * forward_multiplier -
		Input.get_action_strength("move_back") * backward_multiplier
	)
	var target_speed: float = dir * max_speed
	var target_accel: float = acceleration if dir != 0 else deceleration
	speed += target_accel * delta * sign(target_speed - speed)
	
	velocity = -global_transform.basis.z * speed

func vector_rotate(rot: Vector2):
	rotation.y -= deg2rad(rot.x)
	rotation.x += deg2rad(rot.y)

	rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
