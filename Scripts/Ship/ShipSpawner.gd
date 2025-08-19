class_name ShipSpawner
extends Spatial

export var spawn_on_start: bool = true

func _ready() -> void:
	if spawn_on_start:
		PlayerManager.spawner = self
		PlayerManager.respawn()
