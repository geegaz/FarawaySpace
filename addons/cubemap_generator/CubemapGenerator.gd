tool
class_name CubemapGenerator
extends Spatial

# Adapted from https://github.com/mentallysnail/godot-cubemap-generator

const SIDES: int = 6

export var bake_cubemap: bool = false setget generate_cubemap
export var file_name: String = "cubemap"
export(String, DIR) var path: String = "res://"
#export(float, 0.0,5.0) var intensity: float = 1.0
export(int, 8,1024) var resolution: int = 256
export var anti_aliasing : bool = true
export(float, 0.0, 16384.0, 256.0) var shadow_atlas_size: float = 0.0
export(float, EXP, 0.01, 8192.0) var camera_near: float = 0.05
export(float, EXP, 0.1, 8192.0) var camera_far: float = 100.0
export(int, LAYERS_3D_RENDER) var cull_mask: int

func generate_cubemap(value: bool):
	if not value:
		return # Avoid generating the cubemap when saving the scene
	
	var _views: Array
	var _view_textures: Array = []
	
	# Create 6 temporary viewports and their associated camera
	for side in SIDES:
		var _temp_viewport = Viewport.new()
		var _temp_camera = Camera.new()
		match side:
			CubeMap.SIDE_LEFT:
				_temp_camera.rotation_degrees.y = -90
			CubeMap.SIDE_RIGHT:
				_temp_camera.rotation_degrees.y = 90
			CubeMap.SIDE_BOTTOM:
				_temp_camera.rotation_degrees.x = -90
				_temp_camera.rotation_degrees.y = 180
			CubeMap.SIDE_TOP:
				_temp_camera.rotation_degrees.x = 90
				_temp_camera.rotation_degrees.y = -180
			CubeMap.SIDE_FRONT:
				pass # The camera is facing this way by default
			CubeMap.SIDE_BACK:
				_temp_camera.rotation_degrees.y = 180
				
		
		_temp_camera.fov = 90.0
		_temp_camera.cull_mask = cull_mask
		_temp_camera.near = camera_near
		_temp_camera.far = camera_far
		
		_temp_viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
		_temp_viewport.size = Vector2(resolution, resolution)
		_temp_viewport.keep_3d_linear = true
		_temp_viewport.shadow_atlas_size = shadow_atlas_size
		if anti_aliasing: 
			_temp_viewport.msaa = Viewport.MSAA_8X
		
		_temp_viewport.add_child(_temp_camera)
		add_child(_temp_viewport)
		_temp_camera.global_translation = global_translation
		_views.append(_temp_viewport)
	
	# Render every viewport to an array of images
	yield(VisualServer, "frame_post_draw")
	for _temp_viewport in _views:
		yield(VisualServer, "frame_post_draw")
		var _tex: Image = _temp_viewport.get_texture().get_data()
		_tex.generate_mipmaps()
		_tex.flip_y()
#		_tex.adjust_bcs(intensity,1.0,1.0) # Godot 4 only
		_view_textures.push_back(_tex)
	
	var _temp_path: = "%s/%s.tres" % [path, file_name]
	var _cubemap = CubeMap.new()
	for side in SIDES:
		_cubemap.set_side(side, _view_textures[side])
	
	_cubemap.take_over_path(_temp_path)
	ResourceSaver.save(_temp_path, _cubemap, ResourceSaver.FLAG_COMPRESS)
	
	for _cleanup in get_children():
		_cleanup.queue_free()
	_view_textures.clear()
	_views.clear()
	
	print("Baked Cubemap. Saved to %s" % _temp_path)
