extends Control

var tween: Tween

@onready var _Resume: Button = $ButtonsContainer/Resume
@onready var _Quit: Button = $ButtonsContainer/Quit

func _ready() -> void:
	_Resume.connect("pressed", Callable(self, "_on_resume_pressed"))
	_Quit.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_resume_pressed()->void:
	UIManager.pause(false)

func _on_quit_pressed()->void:
	UIManager.quit()


func enter_state()->void:
	visible = true
	_Resume.grab_focus()

func exit_state()->void:
	visible = false
