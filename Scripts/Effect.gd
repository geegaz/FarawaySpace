extends Spatial

signal finished(node)

export var destroy_on_finish: bool = true
export var active: bool = true

var emitters: = []
var players: = []
var trails: = []

var active_time: float

# Called when the node enters the scene tree for the first time.
func _ready():
	var children: = get_children()
	for child in children:
		match child.get_class():
			"Particles":
				emitters.append(child)
				child.emitting = active
			"AudioStreamPlayer3D":
				players.append(child)
				if active:
					child.play()
			"Trail3D":
				trails.append(child)
				child.sampling_mode = child.SamplingMode.Idle
	
	active_time = get_max_time()

func _process(delta):
	if not is_active():
		active_time -= delta
	
	if active_time < 0:
		emit_signal("finished", self)
		if destroy_on_finish:
			queue_free()

func stop():
	for emitter in emitters:
		emitter.emitting = false
	for player in players:
		player.playing = false
	for trail in trails:
		trail.sampling_mode = trail.SamplingMode.None

func restart():
	active_time = get_max_time()
	for emitter in emitters:
		emitter.restart()
	for player in players:
		player.play()
	for trail in trails:
		trail.points = []
		trail.sampling_mode = trail.SamplingMode.Idle

func is_active()->bool:
	for emitter in emitters:
		if emitter.emitting:
			return true
	for player in players:
		if player.playing:
			return true
	for trail in trails:
		if trail.points.size() > 0:
			return true
	return false

func get_max_time()->float:
	var time: float = 0.0
	for emitter in emitters:
		time = max(time, emitter.lifetime)
	for player in players:
		time = max(time, player.stream.get_length())
	for trail in trails:
		time = max(time, trail.max_points * get_process_delta_time())
	return time
