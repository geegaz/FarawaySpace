extends Spatial

export(int, 1, 32) var directions: int = 8
export(Vector2) var distance: Vector2 = Vector2(5, 6)
export(float, 0, 1) var margin: float = 0.1
export(float, 0, 1) var amount: float = 0.5
export(float) var smoothing_speed: float = 4
export(bool) var exclude_parent: bool = true
export(int, LAYERS_3D_PHYSICS) var collision_layer: int = 1
# DEBUG
export(Gradient) var debug_gradient: Gradient = Gradient.new()

var exclude: Array = []

onready var space: PhysicsDirectSpaceState = get_world().direct_space_state
onready var parent: Spatial = get_parent_spatial()

func _ready() -> void:
	if exclude_parent and parent:
		exclude.append(parent)

func _physics_process(delta: float) -> void:
	# Get basis vectors
	var forward: Vector3 = -global_transform.basis.z
	var right: Vector3 = global_transform.basis.x
	var down: Vector3 = -global_transform.basis.y
	
	var step: float = (PI*2) / directions
	var ray: Vector3 = down * distance.y + forward * distance.x
	
	var target_dir: Vector3 = Vector3.ZERO
	for i in directions:
		var ray_rotated: Vector3 = ray.rotated(forward, step * i)
		var start: Vector3 = global_transform.origin + ray_rotated * margin
		var end: Vector3 = global_transform.origin + ray_rotated
		var ray_length: float = (end - start).length()
		
		var collision: Dictionary = space.intersect_ray(start, end, exclude, collision_layer)
		
		if not collision.empty():
			var projected_forward: Vector3 = forward - forward.project(collision.normal)
			# Control the amount of correction in this direction
			var distance_amount: float = 1 - start.distance_to(collision.position) / ray_length
			var dot_amount: float = clamp(-forward.dot(collision.normal), 0, 1)
			
			target_dir += projected_forward * distance_amount * dot_amount
	
	if target_dir != Vector3.ZERO and parent:
		target_dir = forward.linear_interpolate(target_dir.normalized(), 1 - exp(-smoothing_speed * amount * delta))
		parent.look_at(parent.global_transform.origin + target_dir, Vector3.UP)
