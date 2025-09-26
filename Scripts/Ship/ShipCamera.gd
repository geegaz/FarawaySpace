extends Camera3D

# Camera following
@export var target: Node3D
@export var offset := Vector3.ZERO
@export var translation_as_offset := true
@export var smoothing: float = 4

func _ready():
	# Setup target
	if translation_as_offset and target:
		offset = position
	top_level = true
	reset_interpolation()

func _process(delta):
	# Follow target
	if target:
		global_transform = global_transform.interpolate_with(get_target_transform(), 1- exp(-smoothing * delta))
		global_rotation = quaternion.slerp(get_target_rotation(),1- exp(-smoothing * delta)).get_euler()

func get_target_transform()->Transform3D:
	if not target:
		return global_transform
	return target.global_transform.translated_local(offset)

func get_target_rotation()->Quaternion:
	if not target:
		return quaternion
	return target.quaternion

func reset_interpolation()->void:
	if target:
		global_transform = get_target_transform()
		global_rotation = get_target_rotation().get_euler()
