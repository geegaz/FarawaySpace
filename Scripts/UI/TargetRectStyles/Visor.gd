extends "../TargetRect.gd"

export var rot_update_step: float = 1.0
export(float, 0, 720) var rot_max_speed: float = 120 # degrees/s
export(float, 0, 1) var rot_randomness: float = 0.5

var rot_speed: float = 0.0
var rot_time: float = 0.0

func _process(delta):
	._process(delta)
	
	rot_time -= delta
	if rot_time < 0:
		var random_speed = rand_range(-1.0, 1.0)
		rot_speed = rot_max_speed * random_speed * rot_randomness
		rot_time = rot_update_step
	
	rect_rotation += rot_speed * delta
