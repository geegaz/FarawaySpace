extends Node

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
	var pause_screen: Control = controls.PauseScreen
	if value:
		pause_screen.enter_state()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		pause_screen.exit_state()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func menu(value: bool)->void:
	var menu_screen: Control = controls.MenuScreen
	if value:
		menu_screen.enter_state()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		menu_screen.exit_state()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		PlayerManager.playing = true

func quit()->void:
	tree.quit()
