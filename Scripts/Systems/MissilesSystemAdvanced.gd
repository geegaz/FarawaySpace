extends Spatial

# Shooting parameters
export var shoot_cooldown: = 0.25
# Missile parameters
export var missile: PackedScene
export var missile_hit_method: String = "missile_hit"

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
	# TODO: nothing, actually
	# movement should be handled by the missiles themselves
	pass

# Shooting should be handled by the parent - or any other object
func fire_missile(target: Spatial = null):
	# Don't fire if the cooldown is not finished yet
	if cooldown > 0.0 or not target:
		return
	cooldown = shoot_cooldown
	
	# TODO: fire actual missile
	
	pass

func missile_hit(collision):
	
	# TODO: call the "hit_method" on the collider
	
	pass

