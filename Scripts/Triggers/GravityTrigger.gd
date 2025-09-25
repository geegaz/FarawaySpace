@tool
class_name GravityTrigger
extends Trigger

func trigger_entered(ship: Ship)->void:
	ship.gravity_enabled = false

func trigger_exited(ship: Ship)->void:
	ship.gravity_enabled = true
