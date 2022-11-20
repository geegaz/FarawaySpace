extends Spatial

export var target: NodePath
export var line: NodePath

export var max_points: int = 10 setget set_max_points
export var max_length: float = 10.0 setget set_max_length
export var constraint_iterations: int = 10
export var gravity: Vector3 = Vector3(0.0, -9.8, 0.0)

var point_poses: PoolVector3Array
var point_prev_poses: PoolVector3Array
var point_masses: PoolRealArray

onready var _Target: = get_node(target) as Spatial
onready var _Line: = get_node(line) as Spatial

func _ready():
	create_rope()

func _process(delta):
	point_poses[0] = global_transform.origin
	if _Target:
		point_poses[-1] = _Target.global_transform.origin
	
	process_positions(delta)
	process_constraints(delta)
	
	if _Line:
		_Line.set("points", point_poses)


# Based on the paper Advanced Character Physics, by Thomas Jakobsen
# http://www.cs.cmu.edu/afs/cs/academic/class/15462-s13/www/lec_slides/Jakobsen.pdf

func process_positions(delta: float):
	var prev_pos: Vector3
	for i in max_points:
		prev_pos = point_poses[i]
		point_poses[i] += point_poses[i] - point_prev_poses[i]
		point_poses[i] += point_masses[i] * gravity * delta * delta
		point_prev_poses[i] = prev_pos

func process_constraints(delta: float):
	var vec: Vector3
	var vec_length: float
	var diff: float
	var inv_mass1: float
	var inv_mass2: float
	var segment_length: float = max_length / (max_points - 1)
	for iteration in constraint_iterations:
		for i in (max_points - 1):
			inv_mass1 = INF if point_masses[i] == 0 else 1.0 / point_masses[i]
			inv_mass2 = INF if point_masses[i+1] == 0 else 1.0 / point_masses[i+1]
			
			vec = point_poses[i+1] - point_poses[i]
			vec_length = vec.length()
			diff = (vec_length - segment_length) / (vec_length * (inv_mass1 + inv_mass2))
			
			point_poses[i] -= inv_mass1 * vec * diff
			point_poses[i+1] += inv_mass2 * vec * diff


func create_rope():
	point_poses = PoolVector3Array()
	point_masses = PoolRealArray()
	
	var start_pos: Vector3 = global_transform.origin
	var target_pos: Vector3
	if _Target:
		target_pos = _Target.global_transform.origin
	else:
		target_pos = start_pos + Vector3.DOWN * max_length

	for i in max_points:
		point_poses.append(start_pos.linear_interpolate(target_pos, float(i) / (max_points - 1)))
		point_masses.append(1.0)
	point_prev_poses = point_poses
	
	# Attach the specified points
	point_masses[0] = 0
	if _Target:
		point_masses[-1] = 0

func set_max_points(value: int):
	max_points = max(value, 2)
	create_rope()

func set_max_length(value: float):
	max_length = value
	create_rope()
