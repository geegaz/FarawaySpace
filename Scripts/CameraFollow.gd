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
	if get_parent() == _Target:
		set_as_toplevel(true)
	
	transform = get_target_transform()
	rotation = get_target_rotation().get_euler()

func _process(delta):
	# Follow target
	if _Target:
		transform = transform.interpolate_with(get_target_transform(), 1- exp(-smoothing * delta))
		rotation = Quat(rotation).slerp(get_target_rotation(),1- exp(-smoothing * delta)).get_euler()

func get_target_transform()->Transform:
	if not _Target:
		return transform
	return _Target.global_transform.translated(offset)

func get_target_rotation()->Quat:
	if not _Target:
		return Quat(rotation)
	return Quat(_Target.rotation)

