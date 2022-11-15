extends Camera

# Camera following
export(Vector3) var offset: = Vector3.ZERO
export(bool) var translation_as_offset: = true
export(float) var smoothing: float = 4

onready var _Target : Spatial = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup target
	if translation_as_offset and _Target:
		offset = translation
	
	set_as_toplevel(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Follow target
	if _Target:
		transform = transform.interpolate_with(_Target.global_transform.translated(offset), 1- exp(-smoothing * delta))
		rotation = Quat(rotation).slerp(Quat(_Target.rotation),1- exp(-smoothing * delta)).get_euler()
	
