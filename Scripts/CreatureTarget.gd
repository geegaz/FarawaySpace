extends RigidBody

export var creature_manager: NodePath
onready var _CreatureManager: Node = get_node_or_null(creature_manager)

func missile_hit(missile: Node, collision: KinematicCollision):
	if not _CreatureManager:
		return
	
	var collider = collision.collider
	if collider == self:
		print("Hit the target")
		queue_free()
	else:
		var part: Node
		var part_index: int = 0
		while part_index < _CreatureManager.parts.size():
			part = _CreatureManager.parts[part_index]
			if part.pieces.has(collider):
				print("Hit a ring")
				part.break_piece(collider)
			
			if part.pieces.empty():
				_CreatureManager.parts.erase(part)
				part.queue_free()
			else:
				part_index += 1
		
