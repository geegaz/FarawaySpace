extends Spatial

# Missile parameters
export var random_start_velocity: float = 0.05
export var use_parent_velocity: = true
export var missile_damping: float = 2.5 # m/s/s
export var missile_thrust_force: float = 200.0 # m/s
export var missile_lifetime: float = 10.0
export(int, LAYERS_3D_PHYSICS) var missile_mask: int = 0
export var missile_hit_method: String = "missile_hit"
# Shooting parameters
export var shoot_cooldown: = 0.25
# Effect parameters
export var missile_effect: PackedScene
export var hit_effect: PackedScene

class Missile:
	var transform: Transform
	var velocity: Vector3
	var life: float
	
	var target: Spatial
	var effect: Spatial

var missiles: = []

var cooldown: = 0.0

onready var _Missiles: Node = $Missiles
onready var _Effects: Node = $Effects
onready var space: PhysicsDirectSpaceState = get_world().direct_space_state

#export var targeting_system: NodePath
#onready var _TargetingSystem: Spatial = get_node(targeting_system) as Spatial

func _ready():
	pass

func _process(delta):
	cooldown = max(cooldown - delta, 0.0)

func _physics_process(delta: float) -> void:
	var missile: Missile
	var index: int = 0
	while index < missiles.size():
		missile = missiles[index]
		
		var dir: Vector3 = -missile.transform.basis.z
		if is_instance_valid(missile.target):
			missile.transform = missile.transform.looking_at(missile.target.global_transform.origin, Vector3.UP)
		missile.velocity = missile.velocity.linear_interpolate(Vector3.ZERO, delta * missile_damping)
		missile.velocity += dir * missile_thrust_force * delta
		
		var movement: Vector3 = missile.velocity * delta
		var collision: Dictionary = space.intersect_ray(
			missile.transform.origin, 
			missile.transform.origin + movement, 
			[], 
			missile_mask)
		
		if collision.empty():
			index += 1;
			missile.transform.origin += movement
			if missile.effect:
				missile.effect.transform = missile.transform
		else:
			missile_hit(missile, collision)
			missile.transform.origin = collision.position
			if missile.effect:
				missile.effect.transform = missile.transform
				missile.effect.stop()
			
			var col: Spatial = collision.collider
			if col.has_method(missile_hit_method):
				col.call(missile_hit_method, missile, collision)
			
			missiles.remove(index)

# Shooting should be handled by the parent - or any other object
#func _unhandled_input(event):
#	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
#		if event.pressed and cooldown == 0.0:
#			fire_missile()
#			cooldown = shoot_cooldown

func fire_missile(target: Spatial = null):
	# Don't fire if the cooldown is not finished yet
	if cooldown > 0.0:
		return
	cooldown = shoot_cooldown
	
	var new_missile: Missile = Missile.new()
	new_missile.transform = global_transform
	new_missile.velocity = Vector3.ZERO
	new_missile.life = missile_lifetime
	
	# Don't create a missile effect if there is no effect set
	if missile_effect:
		var new_effect = missile_effect.instance()
		new_effect.transform = new_missile.transform
		_Effects.add_child(new_effect)
		
		new_missile.effect = new_effect
	
	# Target should be provided by the parent - or any other object
#	if _TargetingSystem:
#		var targets: Array = _TargetingSystem.get_visible_targets()
#		if targets.size() > 0:
#			target_index = (target_index + 1) % targets.size()
#			new_missile.target = targets[target_index]
	new_missile.target = target
	
	missiles.append(new_missile)
	
	# Set random velocity
	var random_angle: float = randf() * TAU
	new_missile.velocity = global_transform.basis.xform(Vector3(cos(random_angle), sin(random_angle), 0.0))
	new_missile.velocity *= missile_thrust_force * random_start_velocity
	# Add velocity from parent
	var parent_velocity: Vector3 = get_parent().get("velocity")
	if use_parent_velocity and parent_velocity:
		new_missile.velocity += parent_velocity

func missile_hit(missile: Missile, collision):
	# print("Missile %s hit %s"%[missile, collision.collider.name])
	# Don't create a hit effect if there is no effect set
	if not hit_effect:
		return
	
	var new_effect: Spatial
	# Hit effect
	new_effect = hit_effect.instance()
	_Effects.add_child(new_effect)
	new_effect.restart()
	new_effect.transform = missile.transform

