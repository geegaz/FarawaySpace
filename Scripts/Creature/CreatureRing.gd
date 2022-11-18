extends "CreaturePart.gd"

export var target: NodePath
export var intact_part: NodePath
export var broken_part: NodePath
# Pieces parameters
export var explosion_force: float = 500
export(float, 0.0, 1.0) var explosion_force_random: float = 0.8
export var explosion_use_mass: bool = false
export var explosion_effect: PackedScene
export var pieces_effect: PackedScene

var broken: bool = false

onready var _Target: Node = get_node(target)
onready var _IntactPart: Spatial = get_node(intact_part)
onready var _BrokenPart: Spatial = get_node(broken_part)
onready var pieces: = get_pieces()

func _ready()->void:
#	rotate_object_local(Vector3.UP, deg2rad(offset * rotation_offset))
	_Target.connect("target_hit", self, "explode")
	_IntactPart.visible = true
	for piece in pieces:
		piece.visible = false
		piece.source = self



func get_pieces()->Array:
	var _pieces: = []
	for child in _BrokenPart.get_children():
		if child is RigidBody:
			_pieces.append(child)
	return _pieces

func set_pieces_visible(value: bool):
	_IntactPart.visible = not value
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
	Screenshake.add_shake(0.5)
	if pieces_effect:
		var new_effect = pieces_effect.instance()
		piece.add_child(new_effect)
	# Cleanup
	pieces.erase(piece)

func explode():
	# Break every piece
	while pieces.size() > 0:
		break_piece(pieces.back())
	# Visual effects
	if explosion_effect:
		var new_effect = explosion_effect.instance()
		new_effect.set_as_toplevel(true)
		add_child(new_effect)
#		yield(new_effect, "finished")
