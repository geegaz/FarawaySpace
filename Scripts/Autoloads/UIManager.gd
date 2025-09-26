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

func quit()->void:
	tree.quit()


func add_layer(layer_name: String, layer_index: int)->void:
	if layers.has(layer_name):
		return # Layer already exists
	var layer: = CanvasLayer.new()
	layer.name = layer_name
	layer.layer = layer_index
	layers[layer_name] = layer
	add_child(layer)

func remove_layer(layer_name: String)->void:
	if not layers.has(layer_name):
		return # No layer with that name
	var layer: CanvasLayer = layers[layer_name]
	layer.queue_free()
	layers.erase(layer_name)
	
	# Remove all attached controls
	for control in control_layers.keys(): # use keys to not break the loop when erasing keys
		if control_layers[control] == layer_name:
			# Remove the controls manually instead of relying on remove_control
			controls[control].queue_free()
			controls.erase(control)
			control_layers.erase(control)


func add_control(control_name: String, control_scene: PackedScene)->void:
	if controls.has(control_name):
		return # Control already exists
	if not control_scene:
		return # No scene provided
	var control: Control = control_scene.instantiate()
	control.name = control_name
	controls[control_name] = control

func remove_control(control_name: String)->void:
	if not controls.has(control_name):
		return # No control with that name
	var control: Control = controls[control_name]
	control.queue_free()
	controls.erase(control_name)
	# Remove the relation to its layer
	if control_layers.has(control_name):
		control_layers.erase(control_name)

func add_control_to_layer(control_name: String, layer_name: String)->void:
	if not layers.has(layer_name):
		return # No layer with that name
	if not controls.has(control_name):
		return # No control with that name
	
	var layer: CanvasLayer = layers.get(layer_name)
	var control: Control = controls.get(control_name)
	var control_parent: Node = control.get_parent()
	
	if not control_parent:
		layer.add_child(control)
		# Add the relation
		control_layers[control_name] = layer_name
	else:
		printerr("Can't add control %s to layer %s: control is already child of %s"%[
			control, layer, control_parent])

func remove_control_from_layer(control_name: String, layer_name: String)->void:
	if not layers.has(layer_name):
		return # No layer with that name
	if not controls.has(control_name):
		return # No control with that name
	
	var layer: CanvasLayer = layers.get(layer_name)
	var control: Control = controls.get(control_name)
	var control_parent: Node = control.get_parent()
	
	if control_parent == layer:
		layer.remove_child(control)
		# Remove the relation
		control_layers.erase(control_name)
	elif control_parent == null:
		printerr("Can't remove control %s from layer %s: control has no parent"%[
			control, layer])
	else:
		printerr("Can't remove control %s from layer %s: control is already child of %s"%[
			control, layer, control_parent])
