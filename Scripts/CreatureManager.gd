extends Spatial

export(Array, NodePath) var managed_parts: = []
onready var parts: = get_managed_parts()

func get_managed_parts()->Array:
	var parts: = []
	for part_path in managed_parts:
		parts.append(get_node(part_path))
	return parts
