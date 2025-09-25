extends Camera3D

# Camera following
@export var target: NodePath
@export var offset := Vector3.ZERO
@export var translation_as_offset := true
@export var smoothing: float = 4

@onready var _Target : Node3D = get_node_or_null(target)

func _ready():
	# Setup target
	if translation_as_offset and _Target:
		offset = position
	top_level = true
	reset_interpolation()

func _process(delta):
	# Follow target
	if _Target:
		global_transform = global_transform.interpolate_with(get_target_transform(), 1- exp(-smoothing * delta))
		global_rotation = quaternion.slerp(get_target_rotation(),1- exp(-smoothing * delta)).get_euler()

func get_target_transform()->Transform3D:
	if not _Target:
		return global_transform
	return _Target.global_transform.translated_local(offset)

func get_target_rotation()->Quaternion:
	if not _Target:
		return quaternion
	return _Target.quaternion

func reset_interpolation()->void:
	if _Target:
		global_transform = get_target_transform()
		global_rotation = get_target_rotation().get_euler()
