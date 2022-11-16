extends KinematicBody

signal hit(missile, collision)

export var damping: float = 2.0 # m/s/s
export var thrust_force: float = 200.0 # m/s
export var lifetime: float = 10.0
export var hit_method: String = "missile_hit"

var target: Spatial
var dir: Vector3
var velocity: Vector3
var life: float = lifetime

onready var _Effect: = $MissileEffect

func _ready():
	dir = -global_transform.basis.z
	if target and target.has_method(hit_method):
		# warning-ignore:return_value_discarded
		connect("hit", target, hit_method)
		

func _physics_process(delta):
	if is_instance_valid(target):
		look_at(target.global_transform.origin, Vector3.UP)
		dir = -global_transform.basis.z
	velocity = velocity.linear_interpolate(Vector3.ZERO, delta * damping)
	velocity += dir * thrust_force * delta
	
	# Collision handling
	var collision: = move_and_collide(velocity * delta)
	if collision:
		hit(collision)
		set_physics_process(false)
	
	# Timeout
	life -= delta
	if life < 0.0:
		queue_free()


func hit(collision: KinematicCollision):
	var col: Node = collision.collider
	if col.has_method(hit_method):
		connect("hit", col, hit_method)
	emit_signal("hit", self, collision)
	
	_Effect.stop()
	yield(_Effect,"finished")
	
	queue_free()
