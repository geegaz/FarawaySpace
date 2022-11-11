extends "../TargetRect.gd"

export var pos_update_step: float = 0.2
export(float, 0, 1) var pos_randomness: float = 0.05
export var size_update_step: float = 0.5
export(float, 0, 1) var size_randomness: float = 0.15
export var rect_title: String = "dog" setget set_rect_title

var pos_time: float = 0.0
var size_time: float = 0.0

onready var _Title: Label = $Label

func _process(delta):
	size_time -= delta
	if size_time < 0:
		rect_size = target_size * target_size_multiplier 
		rect_size += random_vector() * rect_size * size_randomness
		rect_pivot_offset = rect_size / 2.0
		size_time = size_update_step
	
	pos_time -= delta
	if pos_time < 0:
		rect_position = target_pos + random_vector() * rect_size * pos_randomness
		rect_position -= rect_pivot_offset
		pos_time = pos_update_step

func random_vector()->Vector2:
	return Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))

func set_rect_title(value: String):
	rect_title = value
	if _Title:
		_Title.text = value
