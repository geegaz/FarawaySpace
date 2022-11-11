extends Spatial

signal finished(node)

export var destroy_on_finish: bool = true
export var active: bool = true

var emitters: = []
var trails: = []

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = active
	var children: = get_children()
	for child in children:
		match child.get_class():
			"Particles":
				emitters.append(child)
				child.emitting = active
			"Trail3D":
				trails.append(child)
				child.emit = active

func _process(delta):
	active = (emitters_active() or trails_active())
	visible = active
	
	if not active:
		emit_signal("finished", self)
		if destroy_on_finish:
			queue_free()

func stop():
	for emitter in emitters:
		emitter.emitting = false
	for trail in trails:
		trail.emit = false

func restart():
	for emitter in emitters:
		emitter.restart()
	for trail in trails:
		trail.emit = true

func emitters_active()->bool:
	for emitter in emitters:
		if emitter.emitting:
			return true
	return false

func trails_active()->bool:
	for trail in trails:
		if trail.emit or trail.points.size() > 0:
			return true
	return false
