extends Node

signal player_respawned

var player: Ship # Provided by the ship when it enters the tree
var spawner: ShipSpawner # Provided by the spawner when it enters the tree

var respawn_requested: bool

func respawn()->void:
	respawn_requested = true

func _process(delta: float) -> void:
	# Ensure all conditions are met before respawning
	# (player or spawner might not be set yet)
	if respawn_requested and player:
		if spawner:
			player.teleport(spawner.global_translation, spawner.global_rotation)
		else:
			player.teleport(Vector3.ZERO, Vector3.ZERO)
		respawn_requested = false
		emit_signal("player_respawned")
