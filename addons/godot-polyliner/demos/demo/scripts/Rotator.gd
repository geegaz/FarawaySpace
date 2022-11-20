extends Spatial

const AXES: Array = [
	Vector3.RIGHT,
	Vector3.UP,
	Vector3.BACK
]
export(int, "X", "Y", "Z") var rotation_axis: int = 1
export var rotation_local: bool = true
export var rotation_speed: float = 10.0

func _process(delta):
	if rotation_local:
		rotate_object_local(AXES[rotation_axis], rotation_speed * delta)
	else:
		rotate(AXES[rotation_axis], rotation_speed * delta)
