extends ImmediateGeometry

class DebugDrawStep:
	var primitive_type: int
	var vertices: PoolVector3Array
	var color: Color

var queue: Array

func draw_line(start: Vector3, end: Vector3, color: Color)->void:
	var new_step: = DebugDrawStep.new()
	new_step.primitive_type = Mesh.PRIMITIVE_LINES
	new_step.vertices = [start, end]
	new_step.color = color
	queue.append(new_step)

func _process(delta: float) -> void:
	clear()
	for step in queue:
		begin(step.primitive_type)
		for v in step.vertices.size():
			set_color(step.color)
			add_vertex(step.vertices[v])
		end()
	queue.clear()
