extends Control

export var target_pos: Vector2
export var target_size: Vector2
export var target_size_multiplier: float = 1.0

func _process(delta):
	rect_size = target_size * target_size_multiplier
	rect_pivot_offset = rect_size / 2.0
	
	rect_position = target_pos
	rect_position -= rect_pivot_offset
