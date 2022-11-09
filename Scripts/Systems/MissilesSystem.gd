extends Spatial

export var missile: PackedScene
export var hit_effect: PackedScene
export var targeting_system: NodePath

var target_index: int = 0

onready var _Missiles: Node = $Missiles
onready var _HitEffects: Node = $HitEffects
onready var _TargetingSystem: Spatial = get_node(targeting_system) as Spatial
onready var _Camera: Camera = get_viewport().get_camera()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			fire_missile()

func fire_missile():
	var new_missile = missile.instance()
	
	if _TargetingSystem:
		var targets: Array = _TargetingSystem.get_visible_targets()
		if targets.size() > 0:
			target_index = (target_index + 1) % targets.size()
			new_missile._Target = targets[target_index]
	
	new_missile.connect("hit", self, "_on_Missile_hit")
	new_missile.transform = global_transform
	new_missile.dir = -global_transform.basis.z
	
	# Set velocity
	var random_angle = randf() * TAU
	new_missile.velocity = transform.basis.xform(Vector3(cos(random_angle), sin(random_angle), 0.0))
	new_missile.velocity += -new_missile.dir
	new_missile.velocity *= new_missile.max_speed / 2.5
	
	_Missiles.add_child(new_missile)

func _on_Missile_hit(missile: Spatial, collision: KinematicCollision):
	var new_hit_effect = hit_effect.instance()
	
	new_hit_effect.transform = missile.transform
	Screenshake.shake(0.5)
	
	_HitEffects.add_child(new_hit_effect)
