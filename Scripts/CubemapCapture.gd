tool 
class_name CubemapCapture
extends Spatial

# https://www.khronos.org/opengl/wiki/Cubemap_Texture

export var side_size: Vector2 = Vector2(256, 256)
export(int, LAYERS_3D_RENDER) var cull_mask: int
export(String, FILE) var output_path
export var capture: bool = false setget set_capture

func capture(path: String)->void:
	if path == "":
		printerr("Please provide a path for the output Cubemap")
	
	var capture_viewport: Viewport = $CaptureViewport
	var capture_camera: Camera = capture_viewport.get_camera()
	
	capture_viewport.size = side_size
	
	var cubemap: = CubeMap.new()

func capture_image(color: Color)->Image:
	var img: = Image.new()
	img.create(side_size.x, side_size.y, true, Image.FORMAT_RGB8)
	
	img.lock()
	img.fill(color)
	img.unlock()
	
	return img

func set_capture(value: bool)->void:
	if value:
		print("Capturing...")
		# TODO: do capture
	capture = false
