class_name BoundsTrigger
extends Trigger

export var transition_color: Color

func trigger_entered(ship: Ship)->void:
	var transition: Transition = UIManager.controls[UIManager.TRANSITION_NAME]
	if transition:
		var callable: = Callable.new(PlayerManager, "respawn")
		transition.transition(transition_color, callable)
	else:
		PlayerManager.respawn()
