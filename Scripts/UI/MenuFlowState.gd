extends UIFlowState

@export var start_button: Button
@export var quit_button: Button

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed()->void:
	PlayerManager.playing = true

func _on_quit_button_pressed()->void:
	flow.go_to("Quit")

func enter_state()->void:
	start_button.grab_focus()

func exit_state()->void:
	pass
