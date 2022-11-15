extends Camera

export (bool) var movEnabled = true
export (float) var mouseSensitivity = 0.1

var yaw : float = 0.0
var pitch : float = 0.0
var origin: Vector3 = Vector3.ZERO
var dist : float = 6.0
var height : float = 1.5

onready var _Target: Spatial = get_parent_spatial()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_as_toplevel(true)

func _process(delta):
	if _Target:
		var offset: = transform.basis.z * dist + transform.basis.y * height
		origin = origin.linear_interpolate(_Target.global_translation, delta * 12.0)
		translation = origin + offset

func _input(event):
	if event is InputEventMouseMotion:
		var rot: Vector2 = event.relative
		rotation.y -= deg2rad(rot.x * 0.1)
		rotation.x -= deg2rad(rot.y * 0.1)

		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
	
	elif event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
