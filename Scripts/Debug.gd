extends Node

const ENABLED: = true

# Pre-calculated models
const WIRE_CUBE_VERTICES: = PoolVector3Array([
	# Lower edges
	Vector3(-1,-1,-1),
	Vector3(1,-1,-1),
	Vector3(1,-1,-1),
	Vector3(1,-1,1),
	Vector3(1,-1,1),
	Vector3(-1,-1,1),
	Vector3(-1,-1,1),
	Vector3(-1,-1,-1),
	# Middle edges
	Vector3(-1,-1,-1),
	Vector3(-1,1,-1),
	Vector3(1,-1,-1),
	Vector3(1,1,-1),
	Vector3(1,-1,1),
	Vector3(1,1,1),
	Vector3(-1,-1,1),
	Vector3(-1,1,1),
	# Upper edges
	Vector3(-1,1,-1),
	Vector3(1,1,-1),
	Vector3(1,1,-1),
	Vector3(1,1,1),
	Vector3(1,1,1),
	Vector3(-1,1,1),
	Vector3(-1,1,1),
	Vector3(-1,1,-1),
])
const CUBE_VERTICES: = PoolVector3Array([
	# -X
	Vector3(-1,-1,-1),
	Vector3(-1,1,-1),
	Vector3(-1,1,1),
	Vector3(-1,1,1),
	Vector3(-1,-1,1),
	Vector3(-1,-1,-1),
	# +X
	Vector3(1,-1,1),
	Vector3(1,1,1),
	Vector3(1,1,-1),
	Vector3(1,1,-1),
	Vector3(1,-1,-1),
	Vector3(1,-1,1),
	# -Y
	Vector3(-1,-1,1),
	Vector3(1,-1,1),
	Vector3(1,-1,-1),
	Vector3(1,-1,-1),
	Vector3(-1,-1,-1),
	Vector3(-1,-1,1),
	# +Y
	Vector3(1,1,1),
	Vector3(1,1,-1),
	Vector3(-1,1,-1),
	Vector3(-1,1,-1),
	Vector3(-1,1,1),
	Vector3(1,1,1),
	# -Z
	Vector3(1,-1,-1),
	Vector3(1,1,-1),
	Vector3(-1,1,-1),
	Vector3(-1,1,-1),
	Vector3(-1,-1,-1),
	Vector3(1,-1,-1),
	# +Z
	Vector3(-1,-1,1),
	Vector3(-1,1,1),
	Vector3(1,1,1),
	Vector3(1,1,1),
	Vector3(1,-1,1),
	Vector3(-1,-1,1)
])
const CUBE_NORMALS: = PoolVector3Array([
	Vector3.LEFT,
	Vector3.LEFT,
	Vector3.LEFT,
	Vector3.LEFT,
	Vector3.LEFT,
	Vector3.LEFT,
	
	Vector3.RIGHT,
	Vector3.RIGHT,
	Vector3.RIGHT,
	Vector3.RIGHT,
	Vector3.RIGHT,
	Vector3.RIGHT,
	
	Vector3.DOWN,
	Vector3.DOWN,
	Vector3.DOWN,
	Vector3.DOWN,
	Vector3.DOWN,
	Vector3.DOWN,
	
	Vector3.UP,
	Vector3.UP,
	Vector3.UP,
	Vector3.UP,
	Vector3.UP,
	Vector3.UP,
	
	Vector3.FORWARD,
	Vector3.FORWARD,
	Vector3.FORWARD,
	Vector3.FORWARD,
	Vector3.FORWARD,
	Vector3.FORWARD,
	
	Vector3.BACK,
	Vector3.BACK,
	Vector3.BACK,
	Vector3.BACK,
	Vector3.BACK,
	Vector3.BACK
])
const CUBE_UVS: = PoolVector2Array([
	Vector2(0.0, 0.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 0.0),
	Vector2(0.0, 0.0),
	
	Vector2(0.0, 0.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 0.0),
	Vector2(0.0, 0.0),
	
	Vector2(0.0, 0.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 0.0),
	Vector2(0.0, 0.0),
	
	Vector2(0.0, 0.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 0.0),
	Vector2(0.0, 0.0),
	
	Vector2(0.0, 0.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 0.0),
	Vector2(0.0, 0.0),
	
	Vector2(0.0, 0.0),
	Vector2(0.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 1.0),
	Vector2(1.0, 0.0),
	Vector2(0.0, 0.0)
])

var instance_RID: RID
var scenario_RID: RID
var base_RID: RID
var base_material: Material = preload("res://Assets/Materials/debug.tres")

class DrawStep:
	var primitive_type: int
	var vertices: PoolVector3Array
	var normals: PoolVector3Array
	var uvs: PoolVector2Array
	var color: Color = Color.white

var draw_queue: Array

func draw_line(start: Vector3, end: Vector3, color: Color)->void:
	if not ENABLED:
		return
	var new_step: = DrawStep.new()
	new_step.primitive_type = Mesh.PRIMITIVE_LINES
	new_step.vertices = [start, end]
	new_step.color = color
	draw_queue.append(new_step)

func draw_cube(transform: Transform, color: Color)->void:
	if not ENABLED:
		return
	var new_step: = DrawStep.new()
	new_step.primitive_type = Mesh.PRIMITIVE_TRIANGLES
	new_step.vertices = transform.xform(CUBE_VERTICES)
	new_step.normals = transform.xform(CUBE_NORMALS)
	new_step.uvs = CUBE_UVS
	new_step.color = color
	draw_queue.append(new_step)

func draw_wire_cube(transform: Transform, color: Color)->void:
	if not ENABLED:
		return
	var new_step: = DrawStep.new()
	new_step.primitive_type = Mesh.PRIMITIVE_LINES
	new_step.vertices = transform.xform(WIRE_CUBE_VERTICES)
	new_step.color = color
	draw_queue.append(new_step)

func _enter_tree() -> void:
	scenario_RID = get_viewport().world.scenario
	base_RID = VisualServer.immediate_create()
	instance_RID = VisualServer.instance_create2(base_RID, scenario_RID)
	VisualServer.instance_geometry_set_material_override(instance_RID, base_material.get_rid())

func _exit_tree() -> void:
	VisualServer.free_rid(instance_RID)
	VisualServer.free_rid(base_RID)

func _process(delta: float) -> void:
	if not ENABLED:
		return
	_debug_draw()

func _debug_draw()->void:
	VisualServer.immediate_clear(base_RID)
	for step in draw_queue:
		VisualServer.immediate_begin(base_RID, step.primitive_type)
		for v in step.vertices.size():
			VisualServer.immediate_color(base_RID, step.color)
			if step.normals:
				VisualServer.immediate_normal(base_RID, step.normals[v])
			if step.uvs:
				VisualServer.immediate_uv(base_RID, step.uvs[v])
			VisualServer.immediate_vertex(base_RID, step.vertices[v])
		VisualServer.immediate_end(base_RID)
	draw_queue.clear()
