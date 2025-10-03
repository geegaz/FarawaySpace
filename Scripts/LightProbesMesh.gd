@tool
extends Node3D

@export var source: Mesh
@export var source_scale: float = 1.0
@export_tool_button("Generate Probes") var generate_probes: = generate

func _enter_tree() -> void:
	# TODO: display probes position using a multimesh
	pass

func _exit_tree() -> void:
	# TODO: clean up probes display
	pass

func generate()->void:
	for child in get_children():
		if child is LightmapProbe:
			child.queue_free()
	
	var probes: Array[LightmapProbe]
	
	var center_probe: = LightmapProbe.new()
	center_probe.name = "CenterProbe"
	probes.append(center_probe)
	
	if source:
		for surface in source.get_surface_count():
			var arrays: = source.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			
			for index in vertices.size():
				var new_probe: = LightmapProbe.new()
				new_probe.name = "Surface%sProbe%s"%[surface,index]
				new_probe.position = vertices[index] * source_scale
				probes.append(new_probe)
	else:
		printerr("No source mesh provided")
	
	for probe in probes:
		add_child(probe)
		probe.owner = owner
	
	print("Finished generating")
