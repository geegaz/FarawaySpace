extends PathFollow

export var spacing: float = 15

onready var manager: Node = get_parent()

func _process(delta: float) -> void:
	if manager:
		offset += manager.movement_speed * delta
