class_name Spinner
extends Control

@export var rotation_speed: float = 180.0

func _process(delta: float) -> void:
	rotation += deg_to_rad(rotation_speed) * delta
