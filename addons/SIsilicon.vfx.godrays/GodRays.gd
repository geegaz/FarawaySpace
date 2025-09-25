@tool
extends Node3D

var light : Light3D
@export var exposure := 0.5: set = set_exposure
@export var attenuation := 2.0: set = set_attenuation
@export var light_size := 0.5: set = set_light_size

var clouds : Texture2D: set = set_clouds

var canvas : MeshInstance3D
var material := preload("GodRays.tres").duplicate() as ShaderMaterial

func _notification(what : int) -> void:
	if what == NOTIFICATION_PARENTED:
		if get_parent() is Light3D:
			light = get_parent()
	elif what == NOTIFICATION_UNPARENTED:
		light = null
		set_clouds(null)

func _ready() -> void:
	if get_child_count() > 0 and get_child(0).owner == null:
		remove_child(get_child(0))
	
	var mesh := QuadMesh.new()
	mesh.size = Vector2(2, 2)
	mesh.custom_aabb = AABB(Vector3(1,1,1) * -300000, Vector3(1,1,1) * 600000)
	
	canvas = MeshInstance3D.new()
	canvas.name = "GodRay"
	canvas.mesh = mesh
	canvas.material_override = material
	add_child(canvas)
	
	material.setup_local_to_scene()
	
	set_exposure(exposure)
	set_attenuation(attenuation)
	set_light_size(light_size)
	
	set_clouds(null)

func _process(delta : float) -> void:
	if not light:
		material.set_shader_parameter("light_type", 0)
		material.set_shader_parameter("light_pos", Vector3())
		return
	
	var is_directional := light is DirectionalLight3D
	
	material.set_shader_parameter("light_type", not is_directional)
	material.set_shader_parameter("light_color", light.light_color * light.light_energy)
	
	if is_directional:
		var direction := light.global_transform.basis.z
		material.set_shader_parameter("light_pos", direction)
		material.set_shader_parameter("size", light_size)
	else:
		var position := light.global_transform.origin
		material.set_shader_parameter("light_pos", position)
		material.set_shader_parameter("size", light_size * (light as OmniLight3D).omni_range)
	
	material.set_shader_parameter("num_samples", ProjectSettings.get_setting("rendering/quality/godrays/sample_number"))
	material.set_shader_parameter("use_pcf5", ProjectSettings.get_setting("rendering/quality/godrays/use_pcf5"))
	material.set_shader_parameter("dither", ProjectSettings.get_setting("rendering/quality/godrays/dither_amount"))

func set_exposure(value : float) -> void:
	exposure = value
	material.set_shader_parameter("exposure", exposure)
	if canvas:
		canvas.visible = exposure != 0

func set_attenuation(value : float) -> void:
	attenuation = value
	material.set_shader_parameter("attenuate", attenuation)
	if canvas:
		canvas.visible = attenuation != 0

func set_light_size(value : float) -> void:
	light_size = value
	if canvas:
		canvas.visible = light_size != 0

func set_clouds(value : Texture2D) -> void:
	clouds = value
	material.set_shader_parameter("clouds", value)
	material.set_shader_parameter("use_clouds", value != null)
