tool
class_name LevelTrigger
extends Trigger

export var level_data: Resource

func trigger_entered(ship: Ship)->void:
	if level_data:
		SceneManager.change_level(level_data)

#func trigger_exited(ship: Ship)->void:
#	pass
