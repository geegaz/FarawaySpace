extends KinematicBody

export(PackedScene) var _Bullet: PackedScene

# Movement variables
export(float) var max_speed = 20 # m/s
export(float) var acceleration = 5 # m/s/s
export(float) var deceleration = 15 # m/s/s

# Rotation variables
export(float) var rotation_deadzone = 0.05
export(Vector2) var rotation_speed = Vector2(4, 2) # rad/s

var speed: float = 0
var dir: Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO

var shoot_cooldown: float = 0

onready var _StateMachine: AnimationNodeStateMachinePlayback = $ShipVisuals/AnimationTree["parameters/playback"]
onready var _Visuals: Spatial = $ShipVisuals
onready var _Bullets: Node = $Bullets

func _process(delta):
	rotate_y(-dir.x * rotation_speed.x * delta)
	rotation.x = -dir.y * (PI/2)
	
	_Visuals.rotation.z = dir.x * (PI/2)
	
	if speed != 0:
		_StateMachine.travel("move")
	else:
		_StateMachine.travel("idle")
	
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
	elif Input.is_mouse_button_pressed(BUTTON_LEFT):
		shoot()

func _physics_process(delta):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		speed += acceleration * delta
	else:
		speed -= deceleration * delta
	speed = clamp(speed, 0, max_speed)
	
	move_and_slide(-transform.basis.z * speed)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var viewport = get_viewport()
		var viewport_min_size = min(viewport.size.x, viewport.size.y)
		
		var dir_vector = viewport.get_mouse_position() - viewport.size / 2
		var dir_length = clamp(range_lerp(dir_vector.length() / viewport_min_size, rotation_deadzone, 1-rotation_deadzone, 0,1), 0, 1)
		dir = dir_vector.normalized() * dir_length

func shoot():
	_StateMachine.start("shoot")
	shoot_cooldown = 0.5
	
	if _Bullet:
		var new_bullet = _Bullet.instance()
		new_bullet.transform = self.transform
		get_parent().add_child(new_bullet)
