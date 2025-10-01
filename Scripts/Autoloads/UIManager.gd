extends Node

@export var flow: UIFlow

var layers: Dictionary
var controls: Dictionary
var control_layers: Dictionary

@onready var tree: SceneTree = get_tree()
@onready var window: Window = tree.root

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
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
	pause(false)
	if not PlayerManager.playing:
		menu(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		pause(not tree.paused)
	
	if event.is_action_pressed("ui_fullscreen"):
		var target_mode: = Window.MODE_FULLSCREEN
		if window.mode == Window.MODE_FULLSCREEN:
			target_mode = Window.MODE_WINDOWED
		window.mode = target_mode

func pause(value: bool)->void:
	tree.paused = value
	if value:
		flow.go_to("PauseFlowState")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		flow.go_to("GameFlowState")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func menu(value: bool)->void:
	if value:
		flow.go_to("MenuFlowState")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		PlayerManager.playing = false
	else:
		flow.go_to("GameFlowState")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		PlayerManager.playing = true

func quit()->void:
	tree.quit()
