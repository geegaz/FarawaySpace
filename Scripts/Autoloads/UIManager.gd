extends Node

@export var flow: UIFlow
@export var flow_states_with_mouse: Array[StringName]
@export var flow_states_with_background: Array[StringName]

var layers: Dictionary
var controls: Dictionary
var control_layers: Dictionary

@onready var tree: SceneTree = get_tree()
@onready var window: Window = tree.root

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	flow.state_changed.connect(_on_flow_state_changed)
	PlayerManager.started_playing.connect(_on_player_manager_started_playing)
	PlayerManager.stopped_playing.connect(_on_player_manager_stopped_playing)
	
	for child in get_children():
		if child is CanvasLayer:
			layers[child.name] = child
	for layer in layers:
		var layer_node: CanvasLayer = layers[layer]
		for child in layer_node.get_children():
			if child is Control:
				controls[child.name] = child
				control_layers[child.name] = layer

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		if PlayerManager.playing: # We've started the game
			if flow.current_state == "":
				pause(true)
				flow.go_to("Pause")
			elif flow.current_state == "Pause":
				flow.go_back()
				pause(false)
			else:
				flow.go_back()
		else: # Otherwise, we are in the main menu
			if flow.current_state == "Menu":
				flow.go_to("Quit")
			else:
				flow.go_back()
		return # Skip the rest of the function
	
	if event.is_action_pressed("ui_fullscreen"):
		var target_mode: = Window.MODE_FULLSCREEN
		if window.mode == Window.MODE_FULLSCREEN:
			target_mode = Window.MODE_WINDOWED
		window.mode = target_mode

func _on_flow_state_changed(state: StringName)->void:
	var has_mouse: = state in flow_states_with_mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if has_mouse else Input.MOUSE_MODE_CAPTURED
	
	var has_background: = state in flow_states_with_background
	controls.FlowStatesBackground.visible = has_background


func _on_player_manager_started_playing()->void:
	flow.stack.clear()
	flow.go_to("", false)

func _on_player_manager_stopped_playing()->void:
	flow.stack.clear()
	flow.go_to("Menu", false)


func pause(value: bool)->void:
	tree.paused = value

func quit()->void:
	tree.quit()
