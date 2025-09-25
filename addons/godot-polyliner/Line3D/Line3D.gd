@tool
extends Node3D

@export var uv_size = 1.0: set = set_uv_size
@export var material: Material = null: set = set_material

var _linegen = LineGen3D.new()

@export var points = PackedVector3Array(): set = set_points

func set_points(val):
	points = val
	redraw()

func add_point(point : Vector3):
	points.push_back(point)
	redraw()

func clear_points():
	points.clear()

func get_point_count() -> int:
	return points.size()

func get_point_position(i : int) -> Vector2:
	return points[i]

func remove_point(i : int):
	points.remove(i)
	redraw()

func set_point_position(i : int, v : Vector3):
	points[i] = v
	redraw()


func set_uv_size(value):
	uv_size = value
	redraw()

var _mesh_instance = MeshInstance3D.new()
func set_material(mat):
	if mat == null:
		material = load("res://addons/godot-polyliner/default_line_material.tres").duplicate(true)
	if mat is ShaderMaterial:
		material = mat
	_mesh_instance.material_override = material



func _enter_tree():
	add_child(_mesh_instance)
	
	set_uv_size(uv_size)
	set_material(material)
	
	redraw()

func _draw():
	var length = uv_size
	
	print()
	var start = Time.get_ticks_usec()
	_mesh_instance.mesh = _linegen.draw_from_points_strip(points)
	var end = Time.get_ticks_usec()
	print( points.size(), " points, ", (end-start)*0.001, " ms" )

var already_redrawn = false
func redraw():
	_draw()

func _process(delta):
	already_redrawn = false

