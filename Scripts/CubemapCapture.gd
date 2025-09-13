tool 
class_name CubemapCapture
extends Spatial

# https://www.khronos.org/opengl/wiki/Cubemap_Texture

export var side_size: Vector2 = Vector2(256, 256)
export(int, LAYERS_3D_RENDER) var cull_mask: int
export(String, FILE, "*.tres") var output_path
export var capture: bool = false setget set_capture

func capture(path: String)->void:
	if path == "":
		printerr("Please provide a path for the output Cubemap")
	
	var capture_viewport: Viewport = $CaptureViewport
	var capture_camera: Camera = capture_viewport.get_camera()
	
	capture_viewport.size = side_size
	capture_camera.cull_mask = cull_mask
	
	var cubemap: = CubeMap.new()
	cubemap.set_side(CubeMap.SIDE_LEFT, capture_image(capture_viewport))
	cubemap.set_side(CubeMap.SIDE_RIGHT, capture_image(capture_viewport))
	cubemap.set_side(CubeMap.SIDE_TOP, capture_image(capture_viewport))
	cubemap.set_side(CubeMap.SIDE_BOTTOM, capture_image(capture_viewport))
	cubemap.set_side(CubeMap.SIDE_FRONT, capture_image(capture_viewport))
	cubemap.set_side(CubeMap.SIDE_BACK, capture_image(capture_viewport))
	
	ResourceSaver.save(path, cubemap)

func capture_image(viewport: Viewport)->Image:
	VisualServer.force_draw()
	var img: = viewport.get_texture().get_data()
	return img

func set_capture(value: bool)->void:
	if value:
		print("Capturing...")
		capture(output_path)
	capture = false
