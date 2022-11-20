extends RigidBody

signal target_hit

func missile_hit(missile: Node, collision):
	if collision.collider == self:
		emit_signal("target_hit")
		queue_free()
