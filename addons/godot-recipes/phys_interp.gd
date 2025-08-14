extends Spatial
class_name PhysInterp


enum InterpolationMode { POSITION, BASIS, TRANSFORM }
export(InterpolationMode) var interpolation_mode: int = InterpolationMode.TRANSFORM
export var exec_priority: int = 100
onready var tr_cur: Transform = Transform()
onready var tr_old: Transform = Transform()
onready var tr_lerp: Transform = Transform()
onready var suspend: bool = false
onready var target: Spatial = get_parent()


func _ready() -> void:
	Engine.physics_jitter_fix = 0
	set_process_priority(exec_priority)
	set_process(true)
	set_physics_process(true)
	set_as_toplevel(true)
	reset_interpolation()


func _physics_process(_delta: float) -> void:
	tr_old = tr_cur
	tr_cur = target.global_transform


func _process(_delta: float) -> void:
	if suspend:
		return
	# Auto suspend if current equals old transform AND node transform made it to current.
	if tr_cur == tr_old && transform == tr_cur:
		return

	var pif: float = Engine.get_physics_interpolation_fraction()

	if interpolation_mode == InterpolationMode.TRANSFORM:
		transform = tr_old.interpolate_with(tr_cur, pif)
	else:
		tr_lerp = target.global_transform
		if interpolation_mode == InterpolationMode.POSITION:
			tr_lerp.origin = tr_old.origin + ((tr_cur.origin - tr_old.origin) * pif)
		if interpolation_mode == InterpolationMode.BASIS:
			tr_lerp.basis.x = tr_old.basis.x.linear_interpolate(tr_cur.basis.x, pif)
			tr_lerp.basis.y = tr_old.basis.y.linear_interpolate(tr_cur.basis.y, pif)
			tr_lerp.basis.z = tr_old.basis.z.linear_interpolate(tr_cur.basis.z, pif)
		transform = tr_lerp


func reset_interpolation() -> void: 
	tr_cur = target.global_transform
	tr_old = tr_cur
	global_transform = target.global_transform


func suspend_interpolation(state: bool) -> void:
	suspend = state
	set_as_toplevel(!suspend)
	set_process(!suspend)
	set_physics_process(!suspend)
	reset_interpolation()


func set_execution_priority(val: int) -> void:
	exec_priority = val
	set_process_priority(exec_priority)
