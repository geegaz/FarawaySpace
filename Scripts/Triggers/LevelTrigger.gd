tool
class_name LevelTrigger
extends Trigger

export var level_name: String

func trigger_entered(ship: Ship)->void:
	SceneManager.change_level(level_name)

#func trigger_exited(ship: Ship)->void:
#	pass
