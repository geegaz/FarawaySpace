extends Node

## PlayerManager
# Handle creating the player and its input controller, but also respawning

signal started_playing
signal stopped_playing

var player_scene: PackedScene = preload("res://Scenes/Ship.tscn")

var player: Ship
var player_input: ShipInput # From spawn_player
var playing: bool = false: set = set_playing


func _ready() -> void:
	# Create the controller, creating the player is handled by the levels
	player_input = ShipInput.new()
	player_input.enabled = playing
	add_child(player_input)


func set_playing(value: bool)->void:
	if value != playing:
		if value:
			player_input.enabled = true
			started_playing.emit()
		else:
			player_input.enabled = false
			stopped_playing.emit()
	playing = value
