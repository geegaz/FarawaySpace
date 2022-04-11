extends KinematicBody

# Movement variables
export(float) var max_speed = 25 # m/s
export(float) var acceleration = 10 # m/s/s
export(float) var deceleration = 5 # m/s/s
export(float) var forward_multiplier = 1.0
export(float) var backward_multiplier = 0.5

# Rotation variables
#export(float) var rotation_deadzone = 0.05
#export(Vector2) var rotation_speed = Vector2(4, 2) # rad/s
export(Vector2) var mouse_sensitivity: Vector2 = Vector2(0.1, 0.1)
export(Vector2) var controller_sensitivity: Vector2 = Vector2(2.0, 2.0)
export(bool) var invert_y: bool = true
var last_rotation: Vector3 = Vector3.ZERO

var dir: float = 0
var power: float = 0
var speed: float = 0

# Gameplay
onready var _Camera: Camera = $Camera
onready var _TCorrect: RayCast = $TrajectoryCorrection
# Visuals
onready var _AnimTree: AnimationTree = $ShipVisuals/AnimationTree
onready var _Visuals: Spatial = $ShipVisuals
# SFX
onready var _Audio: AudioStreamPlayer3D = $ShipAudio

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Visual rotation
	var rotation_speed := rotation - last_rotation
	var tilt = deg2rad(clamp(rad2deg(-rotation_speed.y) * 20, -90, 90))
	# Framerate-independant lerping
	# https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	_Visuals.rotation.z = lerp(_Visuals.rotation.z, tilt, 1 - exp(-4 * delta))
	last_rotation = rotation
	
	###### Cosmetic effects ######
	
	var speed_amount = speed / max_speed
	# If the ship is being powered
	power = lerp(power, dir, 1 - exp(-4 * delta))
	
	# Camera
	_Camera.fov = lerp(70, 100, speed_amount)
	_Camera.shake_duration = abs(power) * speed_amount
	
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
	# Input management
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * controller_sensitivity
	vector_rotate(input_dir)
	
	# Trajectory correction
	correct_trajectory(delta)
	
	# Movement calculations
	accel_movement(delta)
	move_and_slide(-transform.basis.z * speed)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		vector_rotate(event.relative * mouse_sensitivity)

func accel_movement(delta: float):
	# dir goes from -0.5 to 2
	dir = (
		Input.get_action_strength("move_front") * forward_multiplier -
		Input.get_action_strength("move_back") * backward_multiplier
	)
	var target_speed: float = dir * max_speed
	var target_accel: float = acceleration if dir != 0 else deceleration
	speed += target_accel * delta * sign(target_speed - speed)
	
	#$Label.text = "dir: %s, speed: %s"%[dir, speed]

func vector_rotate(rot: Vector2):
	if invert_y:
		rot.y = -rot.y
	rotation.y -= deg2rad(rot.x)
	rotation.x -= deg2rad(rot.y)

	rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)

func correct_trajectory(delta: float):
	# TODO
	pass
