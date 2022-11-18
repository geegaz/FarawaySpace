extends Spatial

export var hit_method: String = "missile_hit"
# Missile parameters
export var random_start_velocity: float = 0.05
export var use_parent_velocity: = true
# Shooting parameters
export var shoot_cooldown: = 0.25
# Effect parameters
export(float, 0.0, 1.0) var screenshake_directional: float = 0.8
export(float, 1.0, 100.0) var screenshake_distance_multiplier: float = 50.0
export var missile: PackedScene
export var hit_effect: PackedScene

class Missile:
	var lifetime: float
	var damping: float
	var thrust_force: float
	
	var transform: Transform
	var velocity: Vector3
	var target: Spatial
	var life: float = lifetime
	

var cooldown: = 0.0
var target_index: int = 0

onready var _Missiles: Node = $Missiles
onready var _Effects: Node = $Effects

#export var targeting_system: NodePath
#onready var _TargetingSystem: Spatial = get_node(targeting_system) as Spatial

func _ready():
	pass

func _process(delta):
	cooldown = max(cooldown - delta, 0.0)

# Shooting should be handled by the parent - or any other object
#func _unhandled_input(event):
#	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
#		if event.pressed and cooldown == 0.0:
#			fire_missile()
#			cooldown = shoot_cooldown

func fire_missile(target: Spatial = null):
	# Don't fire if there is no missile set
	# or if the cooldown is not finished yet
	if not missile or cooldown > 0.0:
		return
	cooldown = shoot_cooldown
	
	var new_missile: Spatial = missile.instance()
	new_missile.transform = global_transform
	
	# Target should be provided by the parent - or any other object
#	if _TargetingSystem:
#		var targets: Array = _TargetingSystem.get_visible_targets()
#		if targets.size() > 0:
#			target_index = (target_index + 1) % targets.size()
#			new_missile.target = targets[target_index]
	new_missile.target = target
	
	# Set random velocity
	var random_angle: float = randf() * TAU
	new_missile.velocity = global_transform.basis.xform(Vector3(cos(random_angle), sin(random_angle), 0.0))
	new_missile.velocity *= new_missile.thrust_force * random_start_velocity
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
		# Shake screen
		var distance = global_transform.origin.distance_to(collision.position) / screenshake_distance_multiplier
		var screen_pos: Vector2 = Screenshake._Camera.unproject_position(collision.position)
		var screen_pos_collision: Vector2 = Screenshake._Camera.unproject_position(collision.position + collision.normal)
		Screenshake.add_shake(1.0 / distance, 0.8, (screen_pos_collision - screen_pos).angle_to(Vector2.RIGHT))

