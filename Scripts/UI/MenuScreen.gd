extends Control

@export var start_button: Button

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed()->void:
	UIManager.menu(false)

func enter_state()->void:
	visible = true
	start_button.grab_focus()

func exit_state()->void:
	visible = false
