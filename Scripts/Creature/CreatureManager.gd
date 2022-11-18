extends Spatial

export var generate_parts: = true
export(Array, PackedScene) var part_scenes: = []
export(Array, int) var pattern: = []

export var movement_speed: float = 15

var parts: = []

func _ready() -> void:
	if generate_parts:
		generate()

func generate() -> void:
	var new_scene: PackedScene
	var new_node: PathFollow
	var previous_node: PathFollow = null
	
	for id in pattern:
		if id < 0 or id >= part_scenes.size():
			 continue
		
		new_scene = part_scenes[id]
		new_node = new_scene.instance()
		add_child(new_node)
		
		if previous_node:
			new_node.offset = previous_node.offset
			new_node.offset += (new_node.spacing + previous_node.spacing) * 0.5
		previous_node = new_node
		
		parts.append(new_node)
