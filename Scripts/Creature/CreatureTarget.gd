extends RigidBody

signal target_hit

func missile_hit(missile: Node, collision):
	if collision.collider == self:
		emit_signal("target_hit")
		queue_free()
		
		Screenshake.add_shake(1.0, 0.8, Screenshake.get_screenshake_angle(collision.position, collision.normal))
		Input.start_joy_vibration(0, 0.8, 0.8, 0.6)
