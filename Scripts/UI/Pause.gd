extends Control

export(bool) var start_fullscreen := false

onready var _Resume: Button = $ButtonsContainer/Resume
onready var _Quit: Button = $ButtonsContainer/Quit

func _ready() -> void:
	_Resume.connect("pressed",self,"pause",[false])
	_Quit.connect("pressed", get_tree(), "quit")
	
	pause(false)
	OS.window_fullscreen = start_fullscreen

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		pause(not get_tree().paused)
	if event.is_action_pressed("ui_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

func pause(value: bool):
	get_tree().paused = value
	visible = value
	if visible:
		_Resume.grab_focus()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED)
