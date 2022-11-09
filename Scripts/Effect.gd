extends Spatial

export(int, "Destroy", "Hide") var end_behavior: int
export var active: bool = true setget set_active

var emitters: = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var children: = get_children()
	for child in children:
		if child is Particles:
			emitters.append(child)
			child.emitting = active

func _process(delta):
	active = false
	for emitter in emitters:
		if emitter.emitting:
			active = true
	
	if not active:
		if end_behavior == 0:
			queue_free()
		elif end_behavior == 1:
			hide()

func set_active(value: bool):
	for emitter in emitters:
		emitter.restart()
		emitter.emitting = value
	visible = value
	set_process(value)
	
	active = value
