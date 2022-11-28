extends RigidBody

var source: Spatial

func _ready() -> void:
	mode = MODE_KINEMATIC

func missile_hit(missile: Spatial, collision):
	if collision.collider == self and source:
		if source.pieces.has(self):
			source.break_piece(self)
			
			Screenshake.add_shake(0.25, 0.8, Screenshake.get_screenshake_angle(collision.position, collision.normal))
			Input.start_joy_vibration(0, 0.2, 0.2, 0.25)

func explode(force: float, direction: Vector3, use_mass: bool = true):
	mode = MODE_RIGID
	set_as_toplevel(true)
	
	if use_mass:
		force *= mass
	var random_offset: = Vector3(
		rand_range(-1, 1),
		rand_range(-1, 1),
		rand_range(-1, 1))
	apply_impulse(random_offset, force * direction)
	
	var random_lifetime: = 5.0 + randf() * 5.0
	var tween: = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	for child in get_children():
		if child is Spatial:
			tween.parallel().tween_property(child, "scale", Vector3.ZERO, random_lifetime)
	tween.tween_callback(self, "queue_free")
