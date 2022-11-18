extends Spatial

const AXIS: = [
	Vector3.RIGHT,
	Vector3.UP,
	Vector3.BACK
]

# Rotation parameters
export(int, "X", "Y", "Z") var rotation_axis: = 1
export var rotation_speed: float = 45.0 # deg/s
export var rotation_offset: float = 0.0 # deg
export var rotation_global: bool = false

func _ready() -> void:
	do_rotation(deg2rad(rotation_offset))

func _process(delta: float) -> void:
	do_rotation(deg2rad(rotation_speed) * delta)

func do_rotation(angle: float) -> void:
	if rotation_global:
		global_rotate(AXIS[rotation_axis], angle)
	else:
		rotate_object_local(AXIS[rotation_axis], angle)
