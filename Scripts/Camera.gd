extends Camera

# Camera following
export(Vector3) var offset: = Vector3.ZERO
export(bool) var translation_as_offset: = true
export(float) var smoothing: float = 4

onready var _Target : Spatial = get_parent()

# Camera shake
#export var shake_decay: float = 0.8
#export var shake_speed: float = 70
#export var shake_power: int = 2
#export var shake_multiplier: float = 0.1
#
#var shake_duration: float = 0.0
#var noise_pos: float = 0.0
#
#onready var noise = OpenSimplexNoise.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup noise
#	noise.seed = randi()
#	noise.period = 4
#	noise.octaves = 2
	
	# Setup target
	if translation_as_offset and _Target:
		offset = translation
	
	set_as_toplevel(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Follow target
	if _Target:
		transform = transform.interpolate_with(_Target.global_transform.translated(offset), 1- exp(-smoothing * delta))
		rotation = Quat(rotation).slerp(Quat(_Target.rotation),1- exp(-smoothing * delta)).get_euler()
	
	# Shake process
#	if shake_duration > 0.0:
#		shake_duration = max(shake_duration - shake_decay * delta, 0.0)
#
#		var amount = pow(shake_duration, shake_power)
#		h_offset = shake_multiplier * amount * noise.get_noise_2d(noise.seed, noise_pos)
#		v_offset = shake_multiplier * amount * noise.get_noise_2d(noise.seed * 2, noise_pos)
#		noise_pos += delta * shake_speed
