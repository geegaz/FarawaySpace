extends Spatial

export var target_visual: PackedScene
export(int, LAYERS_3D_PHYSICS) var target_mask: int = 0
export(int, LAYERS_3D_PHYSICS) var raycast_mask: int = 0
export(float, 1, 180) var max_targeting_angle: float = 90
export(float, 1, 200) var max_targeting_distance: float = 100
export var target_rect_size: float = 50.0
export(float, EASE) var target_rect_grow: float = 2.0

var targets: Dictionary = {}

onready var space: PhysicsDirectSpaceState = get_world().direct_space_state
onready var _Camera: Camera = get_viewport().get_camera()
onready var _Display: Control = $Display
onready var _Area: Area = $Area
onready var _Shape: CollisionShape = $Area/CollisionShape


func _ready():
	_Area.collision_layer = 0
	_Area.collision_mask = target_mask
	_Area.connect("body_entered",self, "_on_Area_body_entered")
	_Area.connect("body_exited",self, "_on_Area_body_exited")
	
	_Shape.shape = SphereShape.new()
	_Shape.shape.radius = max_targeting_distance

func _process(delta):
	for target in targets:
		# Only update the visual if the target has one
		var visual: Node = targets[target]
		if visual:
			var distance: float = global_transform.origin.distance_to(target.global_transform.origin)
			var target_max_axis = target.scale.max_axis()
			var target_scale: float = target.scale[target_max_axis]
			
			visual.visible = is_target_visible(target) and not _Camera.is_position_behind(target.global_transform.origin)
			visual.target_pos = _Camera.unproject_position(target.global_transform.origin)
			visual.target_size = Vector2.ONE * target_rect_size * target_scale * ease(1.0 - distance / max_targeting_distance, target_rect_grow)


func _on_Area_body_entered(body: Spatial):
	if not targets.has(body):
		var new_visual: Control = null
		# Don't create a new visual if there is not target_visual set
		if target_visual:
			new_visual = target_visual.instance()
			new_visual.visible = false
			_Display.add_child(new_visual)
		
		targets[body] = new_visual

func _on_Area_body_exited(body: Spatial):
	if targets.has(body):
		# Only delete the visual if the target had one
		if targets[body] != null:
			targets[body].queue_free()
		targets.erase(body)


func is_target_visible(target: Spatial)->bool:
	var forward: Vector3 = -global_transform.basis.z
	var diff: Vector3 = target.global_transform.origin - global_transform.origin
	var collision: Dictionary
	
	if forward.angle_to(diff) > deg2rad(max_targeting_angle):
		return false
	
	collision = space.intersect_ray(global_transform.origin, target.global_transform.origin, [], raycast_mask)
	if not collision.empty():
		return false
	
	return true

func get_visible_targets()->Array:
	var visible_targets: = []
	for target in targets:
		if is_target_visible(target):
			visible_targets.append(target)
	
	return visible_targets
