extends Node

export var shake_decay: float = 0.8
export var shake_speed: float = 50
export var shake_power: int = 2
export var shake_multiplier: float = 0.15

var duration: float = 0.0
var noise_pos: float = 0.0

onready var _Camera: Camera = get_parent()
onready var noise = OpenSimplexNoise.new()

func _ready() -> void:
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func _process(delta: float) -> void:
	if duration > 0.0:
		duration = max(duration - shake_decay * delta, 0.0)
		
		var amount = pow(duration, shake_power)
		_Camera.h_offset = shake_multiplier * amount * noise.get_noise_2d(noise.seed * 2, noise_pos)
		_Camera.v_offset = shake_multiplier * amount * noise.get_noise_2d(noise.seed * 2, noise_pos)
		noise_pos += delta * shake_speed
