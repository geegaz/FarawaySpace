class_name ShipSpawner
extends Spatial

export var ship: NodePath
export var spawn_on_start: bool = true

func _ready() -> void:
	if spawn_on_start:
		spawn()

func spawn()->void:
	var ship_node: Ship = get_node_or_null(ship)
	if not ship_node:
		return
	ship_node.teleport(global_translation, global_rotation)
