extends Node

enum {
	LOG,
	WARNING,
	ERROR
}

onready var _DebugDraw: ImmediateGeometry = $DebugDraw
onready var _DebugWrite: Label = $DebugWrite

class DrawStep:
	var primitive_type: int
	var vertices: PoolVector3Array
	var color: Color

var draw_queue: Array
var write_queue: Dictionary

func draw_line(start: Vector3, end: Vector3, color: Color)->void:
	var new_step: = DrawStep.new()
	new_step.primitive_type = Mesh.PRIMITIVE_LINES
	new_step.vertices = [start, end]
	new_step.color = color
	draw_queue.append(new_step)

func write_to_screen(category: String, text: String)->void:
	if not write_queue.has(category):
		write_queue[category] = []
	write_queue[category].append(text)

func write(text: String, type: int = LOG)->void:
	var timestamp: = Time.get_time_string_from_system()
	var message: = "%s %s"%[timestamp,text]
	match type:
		LOG:
			print(message)
		WARNING:
			push_warning(message)
		ERROR:
			push_error(message)

func _process(delta: float) -> void:
	_debug_draw()
	_debug_write()

func _debug_draw()->void:
	_DebugDraw.clear()
	for step in draw_queue:
		_DebugDraw.begin(step.primitive_type)
		for v in step.vertices.size():
			_DebugDraw.set_color(step.color)
			_DebugDraw.add_vertex(step.vertices[v])
		_DebugDraw.end()
	draw_queue.clear()

func _debug_write()->void:
	var text: String = ""
	for key in write_queue:
		text += "%s\n"%key
		for i in write_queue[key].size():
			text += "  %s\n"%write_queue[key][i]
	_DebugWrite.text = text
	write_queue.clear()
