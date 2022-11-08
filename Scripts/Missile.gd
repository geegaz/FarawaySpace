extends KinematicBody

signal hit(body)

export var guiding_amount: float = 10
export var max_speed: float = 100
export var acceleration: float = 80
export var lifespan: float = 10

var life: float = 0.0
var speed: float = 0.0
var dir: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO
var collision: KinematicCollision

var _Target: Spatial

# Note: Need to set the dir
func _physics_process(delta):
	if _Target:
		dir = global_transform.origin.direction_to(_Target.global_transform.origin)
		look_at(global_transform.origin + dir, Vector3.UP)
	
	speed = lerp(speed, max_speed, delta * acceleration)
	velocity = velocity.linear_interpolate(dir * speed, delta * guiding_amount)
	
	collision = move_and_collide(velocity * delta)
	if collision:
		emit_signal("hit", collision.collider)
		queue_free()
	
	life += delta
	if life > lifespan:
		queue_free()
