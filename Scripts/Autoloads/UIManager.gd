extends Node

const PAUSE_NAME: = "Pause"
const TRANSITION_NAME: = "Transition"

const DEFAULT_LAYERS: = {
	"SceneUI": 2,
	"LevelUI": 1
}
const DEFAULT_CONTROLS: = {
	PAUSE_NAME: preload("res://Scenes/UI/Pause.tscn"),
	TRANSITION_NAME: preload("res://Scenes/UI/Transition.tscn")
}
const DEFAULT_SETUP: = {
	"SceneUI":[
		PAUSE_NAME,
		TRANSITION_NAME
	]
}

var layers: Dictionary
var controls: Dictionary


func _enter_tree() -> void:
	for layer in DEFAULT_LAYERS:
		add_layer(layer, DEFAULT_LAYERS[layer])
	for control in DEFAULT_CONTROLS:
		add_control(control, DEFAULT_CONTROLS[control])
	for layer in DEFAULT_SETUP:
		for control in DEFAULT_SETUP[layer]:
			add_control_to_layer(control, layer)


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


func add_control(control_name: String, control_scene: PackedScene)->void:
	if controls.has(control_name):
		return # Control already exists
	if not control_scene:
		return # No scene provided
	var control: Control = control_scene.instance()
	control.name = control_name
	controls[control_name] = control

func remove_control(control_name: String)->void:
	if not controls.has(control_name):
		return # No control with that name
	var control: Control = controls[control_name]
	control.queue_free()
	controls.erase(control_name)

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
	elif control_parent == null:
		printerr("Can't remove control %s from layer %s: control has no parent"%[
			control, layer])
	else:
		printerr("Can't remove control %s from layer %s: control is already child of %s"%[
			control, layer, control_parent])
