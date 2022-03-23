extends KinematicBody

# Movement variables
export(float) var max_speed = 20 # m/s
export(float) var min_speed = -5 # m/s
export(float) var acceleration = 5 # m/s/s
export(float) var braking = 10 # m/s/s
export(float) var deceleration = 7 # m/s/s
export(float) var upper_limit = 100 # m
export(float) var lower_limit = 2 # m

# Rotation variables
export(float) var rotation_deadzone = 0.05
export(Vector2) var rotation_speed = Vector2(4, 2) # rad/s

var speed: float = 0
var dir: Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO

#onready var _StateMachine: AnimationNodeStateMachinePlayback = $ShipVisuals/AnimationTree["parameters/playback"]
onready var _AnimTree: AnimationTree = $ShipVisuals/AnimationTree
onready var _Visuals: Spatial = $ShipVisuals

func _process(delta):
	rotate_y(-dir.x * rotation_speed.x * delta)
	rotation.x = -dir.y * (PI/2)
	# Visual rotation
	_Visuals.rotation.z = dir.x * (PI/2)
	
	_AnimTree.set("parameters/speed/blend_position", speed / max_speed * 2)
#	if abs(speed) > 0.1:
#		_StateMachine.travel("move")
#	else:
#		_StateMachine.travel("idle")

func _physics_process(delta):
	accel_movement(delta)
#	lerp_movement(delta)
	move_and_slide(-transform.basis.z * speed)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var viewport = get_viewport()
		var viewport_min_size = min(viewport.size.x, viewport.size.y)
		
		var dir_vector = viewport.get_mouse_position() - viewport.size / 2
		var dir_length = clamp(range_lerp(dir_vector.length() / viewport_min_size, rotation_deadzone, 1-rotation_deadzone, 0,1), 0, 1)
		dir = dir_vector.normalized() * dir_length

func accel_movement(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		speed = min(speed + acceleration * delta, max_speed) 
	elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
		speed = max(speed - braking * delta, min_speed)
	else:
		# Math instead of tests
		speed = sign(speed) * max(abs(speed) - deceleration * delta, 0)
#		if speed > 0:
#			speed = max(speed - deceleration * delta, 0)
#		elif speed < 0:
#			speed = min(speed + deceleration * delta, 0)

func lerp_movement(delta):
	var target_speed: float = 0
	var accel: float = acceleration
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		target_speed = max_speed
	elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
		target_speed = min_speed
	else:
		accel = deceleration
	# Framerate-independant lerping
	# https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	speed = lerp(speed, target_speed, 1 - exp(-accel * delta))
	speed = clamp(speed, min_speed, max_speed)
