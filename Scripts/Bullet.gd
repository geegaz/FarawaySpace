extends KinematicBody

export var speed: float = 120 #m/s

var life: float = 10

func _physics_process(delta: float) -> void:
	life -= delta
	
	var collision = move_and_collide(-transform.basis.z * speed * delta)
	if collision:
		queue_free()
	elif life <= 0:
		queue_free()
