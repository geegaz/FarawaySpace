extends Spatial

export var part: PackedScene
export var ring: PackedScene

export var parts_amount: int = 9
export var movement_speed: float = 15
export var pieces_spacing: float = 18.0

var parts: = []

func _ready() -> void:
	for index in parts_amount:
		var new_part: Node
		if index % 2 == 1 and ring:
			new_part = ring.instance()
		elif part:
			new_part = part.instance()
		
		if new_part:
			parts.append(new_part)
			new_part.offset = pieces_spacing * index
			add_child(new_part)

func _physics_process(delta: float) -> void:
	for part in parts:
		part.offset += movement_speed * delta

func remove_ring(ring: Node):
	pass
