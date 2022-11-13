extends Node

var layers: = []

onready var _Camera: = get_viewport().get_camera()
onready var noise: = OpenSimplexNoise.new()

class Layer:
	enum {
		MODE_MIX,
		MODE_ADD,
		MODE_REPLACE
	}
	
	var mode: int
	
	var intensity: float
	var time: float
	
	var offset: Vector2
	var offset_multiplier: Vector2
	
	func _init(mode: int = MODE_MIX)->void:
		pass
	
	func _process(delta: float)->void:
		pass
	
	
	func shake(time: float, intensity: float, speed: float, decay: float = 0.8, directional: = 0.0, angle: = 0.0)->void:
		pass
	
	func shake_impulse(intensity: float, speed: float, decay: float = 0.8, directional: = 0.0, angle: = 0.0)->void:
		pass


func _process(delta: float) -> void:
	pass
#	_Camera.h_offset = offset.x
#	_Camera.v_offset = offset.y

func get_layer(id: int)->Layer:
	if id >= layers.size():
		return null
	return layers[id]

func set_layer(id: int, layer: Layer):
	if id >= layers.size():
		layers.resize(id + 1)
	layers[id] = layer
