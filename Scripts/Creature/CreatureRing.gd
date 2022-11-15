extends PathFollow

# Rotation parameters
export var rotator_node: NodePath
export var rotation_speed: float = 45.0 # deg/s
export var rotation_offset: float = 0.35
# Pieces parameters
export var intact_node: NodePath
export var explosion_force: float = 500
export(float, 0.0, 1.0) var explosion_force_random: float = 0.8
export var explosion_use_mass: bool = false
export var explosion_effect: PackedScene
export var pieces_effect: PackedScene

var broken: bool = false

onready var rotator: Spatial = get_node(rotator_node)
onready var intact: Spatial = get_node(intact_node)
onready var pieces: = get_pieces()

func _ready()->void:
	rotator.rotate_object_local(Vector3.UP, deg2rad(offset * rotation_offset))
	intact.visible = true
	for piece in pieces:
		piece.visible = false
		piece.source = self

func _physics_process(delta: float) -> void:
	rotator.rotate_object_local(Vector3.UP, deg2rad(rotation_speed) * delta)



func get_pieces()->Array:
	var _pieces: = []
	for child in rotator.get_children():
		if child is RigidBody:
			_pieces.append(child)
	return _pieces

func set_pieces_visible(value: bool):
	intact.visible = not value
	for piece in pieces:
		piece.visible = value

func break_piece(piece: RigidBody):
	if not broken:
		set_pieces_visible(true)
		broken = true
	
	# Explosion impulse
	var direction = global_transform.origin.direction_to(piece.global_transform.origin) 
	var force = explosion_force * (1.0 - randf() * explosion_force_random)
	piece.explode(force, direction, explosion_use_mass)
	
	# Visual effects
	Screenshake.add_shake(0.2)
	if pieces_effect:
		var new_effect = pieces_effect.instance()
		piece.add_child(new_effect)
	
	# Cleanup
	pieces.erase(piece)


func explode():
	if explosion_effect:
		var new_effect = explosion_effect.instance()
		new_effect.set_as_toplevel(true)
		add_child(new_effect)
	while pieces.size() > 0:
		break_piece(pieces.back())
