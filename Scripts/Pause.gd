extends Control

func _ready() -> void:
	pause(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause(!get_tree().paused)
	if event.is_action_pressed("ui_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func pause(value: bool) -> void:
	visible = value
	get_tree().paused = value
#	if value:
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	else:
#		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
