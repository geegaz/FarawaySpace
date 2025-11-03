class_name ThreadTrigger
extends Trigger

signal entered(ship: Ship)

@export var active: bool : 
	set = set_active
@export var visual: MeshInstance3D

func trigger_entered(ship: Ship)->void:
	entered.emit(ship)

func trigger_exited(ship: Ship)->void:
	pass

func set_active(value: bool)->void:
	active = value
	if visual:
		visual.visible = active
