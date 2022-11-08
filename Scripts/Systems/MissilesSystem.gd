extends Spatial

export var missile: PackedScene = preload("res://Scenes/Missile.tscn")
export var targeting_system: NodePath

var missiles: Array = []
var target_index: int = 0

onready var _TargetingSystem: Spatial = get_node(targeting_system) as Spatial

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
	
	var random_angle = randf() * TAU
	new_missile.dir = -global_transform.basis.z
	new_missile.set_as_toplevel(true)
	add_child(new_missile)
