extends Node

onready var _Camera: = get_viewport().get_camera()
onready var noise: = OpenSimplexNoise.new()

var shake_power: int = 2
var shake_decay: float = 0.8
var shake_speed: float = 80.0
var shake_intensity: float = 2.0

var duration: float = 0.0
var noise_pos: float = 0.0

var offset: Vector2
var offset_multiplier: Vector2 = Vector2.ONE
var offset_transform: Transform2D

func _ready() -> void:
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func _process(delta: float)->void:
	if duration > 0.0:
		duration -= max(shake_decay * delta, 0.0)
		
		var amount: float = pow(duration, shake_power)
		offset.x = offset_multiplier.x * shake_intensity * amount * noise.get_noise_2d(noise.seed, noise_pos)
		offset.y = offset_multiplier.y * shake_intensity * amount * noise.get_noise_2d(noise.seed * 2, noise_pos)
		offset = offset_transform.xform(offset)
		noise_pos += delta * shake_speed
	
		_Camera.h_offset = offset.x
		_Camera.v_offset = offset.y

func set_shake(strength: float, directional: = 0.0, angle: = 0.0)->void:
	if duration < strength:
		duration = min(strength, 1.0)
		offset_transform = Transform2D(angle, Vector2.ZERO)
		offset_multiplier = Vector2(1.0 + directional, 1.0 - directional)

func add_shake(strength: float, directional: = 0.0, angle: = 0.0)->void:
	set_shake(duration + strength, directional, angle)
	
static func get_screenshake_angle(pos: Vector3, normal: Vector3)->float:
	var screen_pos: Vector2 = Screenshake._Camera.unproject_position(pos)
	var screen_pos_collision: Vector2 = Screenshake._Camera.unproject_position(pos + normal)
	return (screen_pos_collision - screen_pos).angle_to(Vector2.RIGHT)
