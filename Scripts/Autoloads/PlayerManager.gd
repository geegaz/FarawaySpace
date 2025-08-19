extends Node

signal player_respawned

var player: Ship # Provided by the ship when it enters the tree
var spawner: ShipSpawner # Provided by the spawner when it enters the tree

func respawn()->void:
	if spawner:
		player.teleport(spawner.global_translation, spawner.global_rotation)
	else:
		player.teleport(Vector3.ZERO, Vector3.ZERO)
	emit_signal("player_respawned")
