tool
class_name BoundsTrigger
extends Trigger

export var ship_spawner: NodePath
onready var _ShipSpawner: ShipSpawner = get_node_or_null(ship_spawner)

#func trigger_entered(ship: Ship)->void:
#	pass

func trigger_exited(ship: Ship)->void:
	PlayerManager.respawn()
