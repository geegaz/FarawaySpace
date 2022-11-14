extends PathFollow

export var movement_speed: float = 15.0 # m/s
export var rotation_speed: float = 45.0 # deg/s
export var rotation_offset: float = 0.3
export var explosion_effect: PackedScene
export var pieces_effect: PackedScene
export var explosion_force: float = 80.0
export(float, 0.0, 1.0) var explosion_force_random: float = 0.8

var broken: bool = false

onready var rotator: Spatial = $PartRotator
onready var intact: Spatial = $PartRotator/PartIntact
onready var pieces: = get_pieces()

func _ready() -> void:
	set_pieces_visible(false)
	for piece in pieces:
		piece.mode = RigidBody.MODE_KINEMATIC
	rotator.rotate_object_local(Vector3.UP, deg2rad(offset * rotation_offset))

func _physics_process(delta: float) -> void:
	offset += movement_speed * delta
	rotator.rotate_object_local(Vector3.UP, deg2rad(rotation_speed) * delta)

func get_pieces()->Array:
	var _pieces: = []
	for child in rotator.get_children():
		if child is RigidBody:
			_pieces.append(child)
	return _pieces

func break_piece(piece: RigidBody):
	if not broken:
		set_pieces_visible(true)
		broken = true
	
	piece.mode = RigidBody.MODE_RIGID
	piece.set_as_toplevel(true)
	if pieces_effect:
		var new_effect = pieces_effect.instance()
		piece.add_child(new_effect)
	var direction = piece.transform.origin.normalized()
	var strength = explosion_force * (1.0 - randf() * explosion_force_random)
	piece.apply_impulse(rotator.transform.origin, direction * strength)
	
	pieces.erase(piece)
	Screenshake.add_shake(0.2)
	
	yield(get_tree().create_timer(5.0), "timeout")
	piece.queue_free()

func set_pieces_visible(value: bool):
	intact.visible = not value
	for piece in pieces:
		piece.visible = value

func explode():
	if explosion_effect:
		var new_effect = explosion_effect.instance()
		new_effect.set_as_toplevel(true)
		add_child(new_effect)
	while pieces.size() > 0:
		break_piece(pieces.back())
		
