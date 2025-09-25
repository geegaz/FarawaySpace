@tool
class_name CubemapGenerator
extends Node3D

# Adapted from https://github.com/mentallysnail/godot-cubemap-generator

enum {
	SIDE_RIGHT, # +X
	SIDE_LEFT, # -X
	SIDE_UP, # +Y
	SIDE_DOWN, # -Y
	SIDE_BACK, # +Z
	SIDE_FORWARD # -Z
}

const SIDES: int = 6

@export var file_name: String = "cubemap"
@export_dir var path: String = "res://"
@export_range(0.0, 5.0) var intensity: float = 1.0
@export_range(8, 1024) var resolution: int = 256
@export var anti_aliasing : bool = true
@export_flags_3d_render var cull_mask: int
@export_tool_button("Generate Cubemap") var generate: = generate_cubemap

func generate_cubemap():
	var _views: Array[SubViewport]
	var _view_textures: Array[Image]
	
	# Create 6 temporary viewports and their associated camera
	for side in SIDES:
		var _temp_viewport: = SubViewport.new()
		var _temp_camera: = Camera3D.new()
		match side:
			SIDE_LEFT:
				_temp_camera.rotation_degrees.y = -90
			SIDE_RIGHT:
				_temp_camera.rotation_degrees.y = 90
			SIDE_DOWN:
				_temp_camera.rotation_degrees.x = 90
				_temp_camera.rotation_degrees.y = 180
			SIDE_UP:
				_temp_camera.rotation_degrees.x = -90
				_temp_camera.rotation_degrees.y = -180
			SIDE_FORWARD:
				pass # The camera is facing this way by default
			SIDE_BACK:
				_temp_camera.rotation_degrees.y = 180
				
		
		_temp_camera.fov = 90.0
		_temp_camera.cull_mask = cull_mask
		
		_temp_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_temp_viewport.size = Vector2(resolution, resolution)
		_temp_viewport.scaling_3d_scale = 2.0
		if anti_aliasing: 
			_temp_viewport.msaa_3d = SubViewport.MSAA_8X
		
		_temp_viewport.add_child(_temp_camera)
		add_child(_temp_viewport)
		_temp_camera.global_position = global_position
		
		_views.append(_temp_viewport)
	
	# Render every viewport to an array of images
	await RenderingServer.frame_post_draw
	for _temp_viewport in _views:
		await RenderingServer.frame_post_draw
		var _tex: Image = _temp_viewport.get_texture().get_image()
		_tex.generate_mipmaps()
		_tex.flip_y()
		_tex.adjust_bcs(intensity,1.0,1.0)
		_view_textures.push_back(_tex)
	
	var _temp_path: = "%s/%s.tres" % [path, file_name]
	var _cubemap = Cubemap.new()
	_cubemap.create_from_images(_view_textures)
	
	_cubemap.take_over_path(_temp_path)
	ResourceSaver.save(_cubemap, _temp_path, ResourceSaver.FLAG_COMPRESS)
	
	for _cleanup in get_children():
		_cleanup.queue_free()
	_view_textures.clear()
	_views.clear()
	
	print("Baked Cubemap. Saved to %s" % _temp_path)
