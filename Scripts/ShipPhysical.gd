extends KinematicBody

export var forward_thrust: float = 25.0
export var backward_thrust: float = 20.0
export(float, 0.0, 1.0) var turn_help: float = 0.1
export var damping: float = 0.5

var roll: float = 0.0
var thrust: float = 0.0
var speed: float = 0.0
var speed_amount: float = 0.0
var velocity: Vector3
var prev_velocity: Vector3 = Vector3.ZERO

onready var _Visual: Spatial =  $Visual
onready var _Camera: Camera = $Camera

func _process(delta: float) -> void:
	pass
#	if velocity.length_squared() > 0:
#		var rotation_axis: Vector3 = velocity.normalized()
#		var rotation_angle: float = prev_velocity.signed_angle_to(velocity, Vector3.DOWN) * TAU
#		_Visual.look_at(global_translation + velocity, Vector3.UP)

func _physics_process(delta: float) -> void:
	prev_velocity = velocity
	speed = velocity.length()
	speed_amount = speed / max(forward_thrust, backward_thrust)
	
	var look_direction: Vector3 = -_Camera.transform.basis.z
	var vel_direction: Vector3 = velocity.normalized()
	
	thrust = 0.0
	thrust += Input.get_action_strength("move_front") * forward_thrust
	thrust -= Input.get_action_strength("move_back") * backward_thrust
	
	speed *= 1.0 - damping * delta
	if speed > 0.0:
		velocity = vel_direction.slerp(look_direction, speed_amount * turn_help) * speed
	velocity += look_direction * thrust * delta
	
	velocity = move_and_slide(velocity)
