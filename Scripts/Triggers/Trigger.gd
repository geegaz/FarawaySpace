@abstract
class_name Trigger
extends Area3D

#func _notification(what: int) -> void:
	#match what:
		#NOTIFICATION_ENTER_TREE:
			#body_entered.connect(_on_body_entered)
			#body_exited.connect(_on_body_exited)
		#NOTIFICATION_EXIT_TREE:
			#body_entered.disconnect(_on_body_entered)
			#body_exited.disconnect(_on_body_exited)


func _enter_tree() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _exit_tree() -> void:
	body_entered.disconnect(_on_body_entered)
	body_exited.disconnect(_on_body_exited)

func _on_body_entered(body: Node)->void:
	if body is Ship:
		trigger_entered(body)

func _on_body_exited(body: Node)->void:
	if body is Ship:
		trigger_exited(body)

@abstract func trigger_entered(ship: Ship)->void
@abstract func trigger_exited(ship: Ship)->void
