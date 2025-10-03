extends UIFlowState

@export var start_button: Button

var quit_requested: bool

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed()->void:
	PlayerManager.playing = true

func enter_state()->void:
	start_button.grab_focus()

func exit_state()->void:
	pass

func request_quit()->void:
	quit_requested = true
