extends Camera


export(Vector3) var offset: = Vector3.ZERO
export(bool) var translation_as_offset: = true
export(float) var smoothing: float = 4

export(float) var min_fov = 70
export(float) var max_fov = 100

#export(NodePath) var target: NodePath
onready var _Target : Spatial = get_parent()
onready var _Shake: Node = $CameraShake

# Called when the node enters the scene tree for the first time.
func _ready():
	if translation_as_offset and _Target:
		offset = translation
	
	set_as_toplevel(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _Target:
		transform = transform.interpolate_with(_Target.global_transform.translated(offset), 1- exp(-smoothing * delta))
		rotation = Quat(rotation).slerp(Quat(_Target.rotation),1- exp(-smoothing * delta)).get_euler()
		
		if _Target.is_in_group("ship"):
			fov = lerp(min_fov, max_fov, _Target.speed/_Target.max_speed)
			_Shake.duration = lerp(0, 1, _Target.speed/_Target.max_speed)
