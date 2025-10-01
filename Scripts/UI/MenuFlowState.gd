extends UIFlowState

@export var start_button: Button

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed()->void:
	UIManager.menu(false)

func _enter_state()->void:
	visible = true
	start_button.grab_focus()

func _exit_state()->void:
	visible = false
