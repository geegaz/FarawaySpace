tool
class_name BoundsTrigger
extends Trigger

export var transition_color: Color

export var transition: NodePath
onready var _Transition: Transition = get_node_or_null(transition)

#func trigger_entered(ship: Ship)->void:
#	pass

func trigger_exited(ship: Ship)->void:
	if _Transition:
		var callable: = Callable.new(PlayerManager, "respawn")
		_Transition.transition("bounds", transition_color, transition_color, callable)
	else:
		PlayerManager.respawn()
