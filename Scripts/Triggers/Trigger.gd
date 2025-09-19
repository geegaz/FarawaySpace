class_name Trigger
extends Area

func _enter_tree() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _exit_tree() -> void:
	disconnect("body_entered", self, "_on_body_entered")
	disconnect("body_exited", self, "_on_body_exited")

func _on_body_entered(body: Node)->void:
	if body is Ship:
		trigger_entered(body)

func _on_body_exited(body: Node)->void:
	if body is Ship:
		trigger_exited(body)


func trigger_entered(ship: Ship)->void:
	pass # Override in children classes

func trigger_exited(ship: Ship)->void:
	pass # Override in children classes
