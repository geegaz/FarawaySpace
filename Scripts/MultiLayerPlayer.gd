extends AudioStreamPlayer
class_name MultiLayerPlayer

export(Array, AudioStream) var streams

onready var _Players: Array = create_players()
onready var _Tween = Tween.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(_Tween)
	for player in _Players:
		add_child(player)

func set_layer_active(layer:int, active:bool, time:float = 1.0)->void:
	if layer >= _Players.size():
		return
	var target_player: AudioStreamPlayer = _Players[layer]
	_Tween.remove(target_player, "volume_db")
	
	if time > 0:
		_Tween.interpolate_property(
			target_player, 
			"volume_db",
			target_player.volume_db, 
			volume_db if active else -82,
			time,
			Tween.TRANS_CUBIC,
			Tween.EASE_OUT if active else Tween.EASE_IN
		)
		if not _Tween.is_active():
			_Tween.start()
	else:
		target_player.volume_db = volume_db if active else -82

#func set_layer_volume(layer:int, volume:float)->void:
#	if layer >= _Players.size():
#		return
#	var target_player: AudioStreamPlayer = _Players[layer]
#	target_player.volume_db = volume

func play(from_position:float = 0.0)->void:
	for player in _Players:
		player.play(from_position)

func seek(position: float)->void:
	for player in _Players:
		player.seek(position)

func stop()->void:
	for player in _Players:
		player.stop()


func create_players() -> Array:
	if _Players and _Players.size() > 0:
		for player in _Players:
			player.free()
	
	var new_players := []
	for layer in streams:
		# Duplicate the node only by using instancing
		var new_player: AudioStreamPlayer = duplicate(8)
		new_player.stream = layer
		new_player.volume_db = -82
		new_players.append(new_player)
	
	return new_players
