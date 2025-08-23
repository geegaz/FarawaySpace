class_name ShipSpawner
extends Spatial

export var spawn_on_ready: bool = true


func _ready() -> void:
	if spawn_on_ready:
		PlayerManager.spawner = self
		PlayerManager.respawn()
