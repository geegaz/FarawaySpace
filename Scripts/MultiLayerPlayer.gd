extends Node
class_name MultiLayerPlayer

class Layer extends AudioStreamPlayer:
	var base_volume: float
	var active: bool
	
	func _init(layer_stream: AudioStream, base_volume := 0.0, start_active := false) -> void:
		self.active = start_active
		self.base_volume = base_volume
		
		self.stream = layer_stream
		self.volume_db = base_volume if start_active else -82
	

export(Array, AudioStream) var streams

onready var _Layers: Array = create_layers()
onready var _Tween = Tween.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(_Tween)
	for layer in _Layers:
		add_child(layer)

func set_layer_active(layer:int, active:bool, time:float = 0.0)->void:
	if layer >= _Layers.size():
		return
	
	var target_layer: AudioStreamPlayer = _Layers[layer]
	var target_volume: float = target_layer.base_volume if active else -82
	_Tween.remove(target_layer, "volume_db")
	
	if time > 0:
		_Tween.interpolate_property(
			target_layer.player, 
			"volume_db",
			target_layer.player.volume_db,
			target_volume,
			time,
			Tween.TRANS_CUBIC,
			Tween.EASE_OUT if active else Tween.EASE_IN
		)
		if not _Tween.is_active():
			_Tween.start()
	else:
		target_layer.player.volume_db = target_volume

func set_layer_volume(layer:int, volume:float)->void:
	if layer >= _Layers.size():
		return
	var target_player: AudioStreamPlayer = _Layers[layer]
	target_player.volume_db = volume


func play(from_position:float = 0.0)->void:
	for layer in _Layers:
		layer.play(from_position)

func seek(position: float)->void:
	for layer in _Layers:
		layer.seek(position)

func stop()->void:
	for layer in _Layers:
		layer.stop()


func create_layers() -> Array:
	if _Layers and _Layers.size() > 0:
		for layer in _Layers:
			layer.player.free()
	
	var new_layers := []
	for layer in streams:
		# Duplicate the node only by using instancing
		var new_layer: = Layer.new(layer)
		new_layers.append(new_layer)
	
	return new_layers
