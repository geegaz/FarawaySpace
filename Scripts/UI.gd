extends Control

func _ready() -> void:
	pause(false)
	OS.window_fullscreen = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		pause(not get_tree().paused)
	if event.is_action_pressed("ui_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

func pause(value: bool):
	get_tree().paused = value
	visible = value
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED)
