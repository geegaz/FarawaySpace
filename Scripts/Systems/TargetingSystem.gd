extends Spatial

export var target_rect: PackedScene = preload("res://Scenes/UI/TargetRect.tscn")
export(int, LAYERS_3D_PHYSICS) var mask: int = 1
export(int, LAYERS_3D_PHYSICS) var raycast_mask: int = 1
export(float, 1, 180) var max_targeting_angle: float = 45
export(float, 1, 200) var max_targeting_distance: float = 100
export var target_rect_size: float = 80.0
export(float, EASE) var target_rect_grow: float = 2.0

var targets: Dictionary = {}

onready var space: PhysicsDirectSpaceState = get_world().direct_space_state
onready var _Camera: Camera = get_viewport().get_camera()
onready var _Display: Control = $Display
onready var _Area: Area = $Area
onready var _Shape: CollisionShape = $Area/CollisionShape

func _ready():
	_Area.collision_layer = 0
	_Area.collision_mask = mask
	_Area.connect("body_entered",self, "_on_Area_body_entered")
	_Area.connect("body_exited",self, "_on_Area_body_exited")
	
	_Shape.shape = SphereShape.new()
	_Shape.shape.radius = max_targeting_distance

func _process(delta):
	var forward: Vector3
	var diff: Vector3
	var collision: Dictionary
	
	for target in targets:
		forward = -global_transform.basis.z
		diff = target.global_transform.origin - global_transform.origin
		
		targets[target].visible = false
		# Test if the enemy is visible
		if forward.angle_to(diff) <= deg2rad(max_targeting_angle):
			collision = space.intersect_ray(global_transform.origin, target.global_transform.origin, [], raycast_mask)
			if collision["collider"] == target:
				targets[target].visible = not _Camera.is_position_behind(target.global_transform.origin)
				targets[target].target_pos = _Camera.unproject_position(target.global_transform.origin)
				targets[target].target_size = Vector2.ONE * target_rect_size * ease(1.0 - diff.length() / max_targeting_distance, target_rect_grow)
		

func _on_Area_body_entered(body: Node):
	if not targets.has(body):
		var new_target_rect = target_rect.instance()
		new_target_rect.visible = false
		_Display.add_child(new_target_rect)
		
		targets[body] = new_target_rect

func _on_Area_body_exited(body: Node):
	if targets.has(body):
		targets[body].queue_free()
		targets.erase(body)

func get_visible_targets()->Array:
	var visible_targets: = []
	for target in targets:
		if targets[target].visible:
			visible_targets.append(target)
	
	return visible_targets
