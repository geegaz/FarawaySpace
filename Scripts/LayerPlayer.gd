extends AudioStreamPlayer

export var active := false setget set_active
export(float, -80, 24) var base_volume := 0.0

var transition_time: float = 0.0
var target_volume: float

func _process(delta: float) -> void:
	if transition_time > 0:
		var transition_speed = (target_volume - volume_db) / transition_time
		volume_db = clamp(volume_db + transition_speed * delta, -82, 24)
		
		transition_time = max(transition_time - delta, 0)

func set_active(value: bool, time: float = 0.0):
	active = value
	target_volume = base_volume if active else -82
	
	if time > 0:
		transition_time = time
	else:
		volume_db = target_volume
