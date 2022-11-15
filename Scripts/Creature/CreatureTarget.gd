extends RigidBody

onready var parent: Spatial = get_parent_spatial()

func missile_hit(missile: Node, collision: KinematicCollision):
	if collision.collider == self:
		if parent.has_method("explode"):
			parent.explode()
		queue_free()
