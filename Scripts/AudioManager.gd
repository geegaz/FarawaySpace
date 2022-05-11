extends Node

export(NodePath) var default_player: NodePath

onready var _DefaultPlayer: AudioStreamPlayer = get_node_or_null(default_player)
onready var _CurrentPlayer: AudioStreamPlayer = _DefaultPlayer
onready var _Tween: Tween = $Tween

func fade_to(new_player: AudioStreamPlayer, time = 1.0, volume = 0):
	if time > 0:
		# Setup tween for audio fading in
		_Tween.remove(new_player)
		_Tween.interpolate_property(
			new_player, "volume_db",
			new_player.volume_db, volume,
			time, Tween.TRANS_EXPO, Tween.EASE_OUT
		)
		# Setup tween for audio fading out
		_Tween.remove(_CurrentPlayer)
		_Tween.interpolate_property(
			_CurrentPlayer, "volume_db",
			_CurrentPlayer.volume_db, -80,
			time, Tween.TRANS_EXPO, Tween.EASE_IN
		)
		# Start the tween
		if not _Tween.is_active():
			_Tween.start()
	else:
		_CurrentPlayer.volume_db = -80
		new_player.volume_db = 0
	
	# Change the current player
	_CurrentPlayer = new_player
	print("fading to",_CurrentPlayer,_CurrentPlayer.name)

func fade_area_reverb(area: Area, amount: float, time = 1.0):
	amount = clamp(amount, 0, 1)
	if time > 0:
		# Setup tween for audio fading in
		_Tween.remove(area)
		_Tween.interpolate_property(
			area, "reverb_bus_amount",
			area.reverb_bus_amount, amount,
			time
		)
		# Start the tween
		if not _Tween.is_active():
			_Tween.start()
	else:
		area.reverb_bus_amount = amount
