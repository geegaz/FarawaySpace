extends Node

export(NodePath) var default_player: NodePath

onready var _DefaultPlayer: AudioStreamPlayer = get_node_or_null(default_player)
onready var _CurrentPlayer: AudioStreamPlayer = _DefaultPlayer
onready var _Tween: Tween = $Tween

func fade_to(new_player: AudioStreamPlayer, time = 1.0):
	if new_player == _CurrentPlayer:
		return
	
	if time > 0:
		if new_player:
			# Setup tween for audio fading in
			_Tween.remove(new_player)
			_Tween.interpolate_property(
				new_player, "volume_db",
				new_player.volume_db, linear2db(1),
				time
			)
		if _CurrentPlayer:
			# Setup tween for audio fading out
			_Tween.remove(_CurrentPlayer)
			_Tween.interpolate_property(
				_CurrentPlayer, "volume_db",
				_CurrentPlayer.volume_db, linear2db(0),
				time
			)
		# Start the tween
		if not _Tween.is_active():
			_Tween.start()
	else:
		_CurrentPlayer.volume_db = linear2db(0)
		new_player.volume_db = linear2db(1)
	
	# Change the current player
	_CurrentPlayer = new_player
