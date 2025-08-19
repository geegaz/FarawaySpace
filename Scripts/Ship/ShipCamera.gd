extends Camera

# Camera following
export(NodePath) var target
export(Vector3) var offset: = Vector3.ZERO
export(bool) var translation_as_offset: = true
export(float) var smoothing: float = 4

onready var _Target : Spatial = get_node_or_null(target)

func _ready():
	# Setup target
	if translation_as_offset and _Target:
		offset = translation
	set_as_toplevel(true)
	reset_interpolation()

func _process(delta):
	# Follow target
	if _Target:
		global_transform = global_transform.interpolate_with(get_target_transform(), 1- exp(-smoothing * delta))
		global_rotation = Quat(global_rotation).slerp(get_target_rotation(),1- exp(-smoothing * delta)).get_euler()

func get_target_transform()->Transform:
	if not _Target:
		return global_transform
	return _Target.global_transform.translated(offset)

func get_target_rotation()->Quat:
	if not _Target:
		return Quat(global_rotation)
	return Quat(_Target.global_rotation)

func reset_interpolation()->void:
	if _Target:
		global_transform = get_target_transform()
		global_rotation = get_target_rotation().get_euler()

