extends UIFlowState

var tween: Tween

@export var resume_button: Button
@export var respawn_button: Button
@export var menu_button: Button
@export var quit_button: Button

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	respawn_button.pressed.connect(_on_respawn_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_resume_pressed()->void:
	UIManager.pause(false)
	flow.go_back()

func _on_respawn_pressed()->void:
	UIManager.pause(false)
	flow.go_back()
	# TODO: respawn
	pass

func _on_menu_pressed()->void:
	UIManager.pause(false)
	# TODO: respawn
	PlayerManager.playing = false

func _on_quit_pressed()->void:
	flow.go_to("Quit")



func enter_state()->void:
	resume_button.grab_focus()

func exit_state()->void:
	pass
