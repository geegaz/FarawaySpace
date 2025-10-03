extends UIFlowState

@export var confirm_button: Button
@export var cancel_button: Button

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)

func _on_confirm_button_pressed()->void:
	UIManager.quit()

func _on_cancel_button_pressed()->void:
	flow.go_back()

func enter_state()->void:
	cancel_button.grab_focus()

func exit_state()->void:
	pass
