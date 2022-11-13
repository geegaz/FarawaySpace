extends Spatial

export var targeting_system: NodePath
export var missile: PackedScene
export var hit_effect: PackedScene
# Missile parameters
export var use_parent_velocity: = true
# Shooting parameters
export var shoot_cooldown: = 0.25

var cooldown: = 0.0
var target_index: int = 0

onready var _Missiles: Node = $Missiles
onready var _Effects: Node = $Effects
onready var _TargetingSystem: Spatial = get_node(targeting_system) as Spatial

func _ready():
	pass

func _process(delta):
	cooldown = max(cooldown - delta, 0.0)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
		if event.pressed and cooldown == 0.0:
			fire_missile()
			cooldown = shoot_cooldown

func fire_missile():
	# Don't fire if there is no missile set
	if not missile:
		return
	
	var new_missile: Spatial = missile.instance()
	new_missile.transform = global_transform
	
	if _TargetingSystem:
		var targets: Array = _TargetingSystem.get_visible_targets()
		if targets.size() > 0:
			target_index = (target_index + 1) % targets.size()
			new_missile.target = targets[target_index]
	
	# Set random velocity
	var random_angle: float = randf() * TAU
	new_missile.velocity = global_transform.basis.xform(Vector3(cos(random_angle), sin(random_angle), 2.0))
	new_missile.velocity *= new_missile.thrust_force * 0.1
	# Add velocity from parent
	var parent_velocity: Vector3 = get_parent().get("velocity")
	if use_parent_velocity and parent_velocity:
		new_missile.velocity += parent_velocity
	
	_Missiles.add_child(new_missile)
	new_missile.connect("hit", self, "missile_hit")

func missile_hit(missile: Spatial, collision: KinematicCollision):
	# Don't create a hit effect if there is no effect set
	if not hit_effect:
		return
	
	var new_effect: Spatial
	if missile.target == collision.collider:
		# Hit effect
		new_effect = hit_effect.instance()
		_Effects.add_child(new_effect)
		new_effect.restart()
		new_effect.transform = missile.transform

