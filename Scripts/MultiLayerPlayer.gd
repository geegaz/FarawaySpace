extends AudioStreamPlayer
class_name MultiLayerPlayer

export(Array, AudioStream) var streams

onready var _Layers: Array = create_layers()
onready var _Tween = Tween.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(_Tween)
	for layer in _Layers:
		add_child(layer)

func set_layer_active(layer:int, active:bool, time:float = 1.0)->void:
	if layer >= _Layers.size():
		return
	var target_layer: AudioStreamPlayer = _Layers[layer]
	_Tween.remove(target_layer, "volume_db")
	
	if time > 0:
		_Tween.interpolate_property(
			target_layer, 
			"volume_db",
			target_layer.volume_db,
			volume_db if active else -82,
			time,
			Tween.TRANS_CUBIC,
			Tween.EASE_OUT if active else Tween.EASE_IN
		)
		if not _Tween.is_active():
			_Tween.start()
	else:
		target_layer.volume_db = volume_db if active else -82

#func set_layer_volume(layer:int, volume:float)->void:
#	if layer >= _Layers.size():
#		return
#	var target_player: AudioStreamPlayer = _Layers[layer]
#	target_player.volume_db = volume


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
			layer.free()
	
	var new_layers := []
	for layer in streams:
		# Duplicate the node only by using instancing
		var new_layer: AudioStreamPlayer = duplicate(8)
		new_layer.stream = layer
		new_layer.volume_db = -82
		new_layers.append(new_layer)
	
	return new_layers
