extends UIFlowState

var tween: Tween

@export var resume_button: Button
@export var quit_button: Button

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_resume_pressed()->void:
	UIManager.pause(false)

func _on_quit_pressed()->void:
	UIManager.quit()


func _enter_state()->void:
	visible = true
	resume_button.grab_focus()

func _exit_state()->void:
	visible = false
