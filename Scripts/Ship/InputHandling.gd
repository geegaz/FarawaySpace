class_name InputHandling
extends Node

const MOUSE_MULTIPLIER: float = 0.1
const CONTROLLER_MULTIPLIER: float = 4.0

export var ship: NodePath
onready var _Ship: Ship = get_node_or_null(ship)

export var mouse_sensitivity: float = 0.5
export var mouse_invert_vertical: bool = false
export var controller_sensitivity: float = 0.5
export var controller_invert_vertical: bool = false

var mouse_motion: Vector2

func _ready() -> void:
	Input.use_accumulated_input = false
	
func _process(delta: float) -> void:
	# Turning (with a controller)
	var controller_motion: Vector2 = Input.get_vector("turn_left","turn_right","turn_up","turn_down")
	controller_motion *= controller_sensitivity
	controller_motion *= CONTROLLER_MULTIPLIER
	if controller_invert_vertical:
		controller_motion.y = -controller_motion.y
	
	if _Ship:
		_Ship.forward_input = Input.get_action_strength("move_front")
		_Ship.backward_input = Input.get_action_strength("move_back")
		_Ship.turn_input = mouse_motion + controller_motion
	mouse_motion = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Turning (with the mouse)
		var viewport_transform: Transform2D = get_tree().root.get_final_transform()
		var motion: Vector2 = event.xformed_by(viewport_transform).relative
		motion *= mouse_sensitivity
		motion *= MOUSE_MULTIPLIER
		if mouse_invert_vertical:
			motion.y = -motion.y
		mouse_motion += motion
		return
