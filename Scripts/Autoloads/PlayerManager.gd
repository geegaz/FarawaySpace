extends Node

## PlayerManager
# Handle creating the player and its input controller, but also respawning

signal player_respawned

var player_scene: PackedScene = preload("res://Scenes/Ship.tscn")

var player: Ship
var player_input: ShipInput

var spawner: ShipSpawner # Provided by the spawner when it enters the tree
var respawn_requested: bool = false


func _ready() -> void:
	# Create the controller
	player_input = ShipInput.new()
	add_child(player_input)
	# Creating the player is handled by the levels

func _process(delta: float) -> void:
	# Ensure the player exists before making them respawn
	if respawn_requested and player:
		_respawn()

func respawn()->void:
	respawn_requested = true

func _respawn() ->void:
	if spawner:
		player.teleport(spawner.global_translation, spawner.global_rotation)
	else:
		player.teleport(Vector3.ZERO, Vector3.ZERO)
	respawn_requested = false
	emit_signal("player_respawned")
