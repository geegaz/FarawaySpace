extends Spatial

export var targeting_system: NodePath
export var missile_effect: PackedScene
export var missile_effect_pooling: = true
export var hit_effect: PackedScene
export var hit_effect_pooling: = true
# Missile parameters
export var missile_guiding_amount: float = 10
export var missile_speed: float = 100
export var missile_lifespan: float = 10
export(int, LAYERS_3D_PHYSICS) var missile_mask: int
# Shooting parameters
export var shoot_continuous: bool = true
export var shoot_cooldown: float = 0.25

var fired: bool = false
var cooldown: = 0.0
var target_index: int = 0

class Missile:
	var transform: Transform
	var target: Spatial
	var effect: Spatial
	
	var velocity: Vector3
	var life: float

var missiles: = []
var _MissileEffects: Node
var _HitEffects: Node

onready var space: PhysicsDirectSpaceState = get_world().direct_space_state
onready var _TargetingSystem: Spatial = get_node(targeting_system) as Spatial

func _ready():
	if missile_effect_pooling:
		_MissileEffects = NodePool.new()
		_MissileEffects.original = missile_effect
		add_child(_MissileEffects)
		_MissileEffects.connect_pool("finished", _MissileEffects, "push")
	else:
		_MissileEffects = Node.new()
		add_child(_MissileEffects)
	
	if hit_effect_pooling:
		_HitEffects = NodePool.new()
		_HitEffects.original = hit_effect
		add_child(_HitEffects)
		_HitEffects.connect_pool("finished", _HitEffects, "push")
	else:
		_HitEffects = Node.new()
		add_child(_HitEffects)


func _process(delta):
	cooldown = max(cooldown - delta, 0.0)


func _physics_process(delta):
	var missile: Missile
	var direction: Vector3
	var collision: Dictionary
	
	var index: int = 0
	while index < missiles.size():
		missile = missiles[index]
		
		if missile.target:
			missile.transform = missile.transform.looking_at(missile.target.global_transform.origin, Vector3.UP)
		
		direction = -missile.transform.basis.z
		missile.velocity = missile.velocity.linear_interpolate(direction * missile_speed, delta * missile_guiding_amount)
		
		collision = space.intersect_ray(missile.transform.origin, missile.transform.origin + missile.velocity * delta, [], missile_mask)
		if collision:
			_on_Missile_hit(missile, collision.collider == missile.target)
			delete_missile(missile)
		elif missile.life < 0.0:
			delete_missile(missile)
		else:
			missile.transform.origin += missile.velocity * delta
			missile.effect.transform = missile.transform
			missile.life -= delta
			
			index += 1
		

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
		if event.pressed and cooldown == 0.0:
			fire_missile()
			cooldown = shoot_cooldown

func fire_missile():
	var new_missile: Missile = Missile.new()
	new_missile.transform = global_transform
	new_missile.life = missile_lifespan
	
	# Missile effect
	if missile_effect_pooling:
		new_missile.effect = _MissileEffects.pull()
	else:
		new_missile.effect = missile_effect.instance()
		_MissileEffects.add_child(new_missile.effect)
	new_missile.effect.restart()
	
	if _TargetingSystem:
		var targets: Array = _TargetingSystem.get_visible_targets()
		if targets.size() > 0:
			target_index = (target_index + 1) % targets.size()
			new_missile.target = targets[target_index]
	
	# Set velocity
	var random_angle = randf() * TAU
	new_missile.velocity = global_transform.basis.xform(Vector3(cos(random_angle), sin(random_angle), -1.0))
	new_missile.velocity *= missile_speed / 2.5
	
	missiles.append(new_missile)

func _on_Missile_hit(missile: Missile, hit_target: bool):
	if hit_target:
		# Hit effect
		var new_hit_effect: Spatial
		if hit_effect_pooling:
			new_hit_effect = _HitEffects.pull()
		else:
			new_hit_effect = hit_effect.instance()
			_HitEffects.add_child(new_hit_effect)
		new_hit_effect.restart()
		new_hit_effect.transform = missile.transform
		
		Screenshake.shake(0.5)

func delete_missile(missile: Missile):
	missile.effect.stop()
	missiles.erase(missile)
