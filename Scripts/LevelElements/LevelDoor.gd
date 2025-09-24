class_name LevelDoor
extends Spatial

export var level: Resource
export(Array, NodePath) var petal_animations: Array
export var petal_animation_name: String = "DoorPetal_ARMAction"

onready var _DoorAnimation: AnimationPlayer = $AnimationPlayer

func _enter_tree() -> void:
	var trigger: LevelTrigger = $LevelTrigger
	trigger.level = level
	trigger.visible = false

func open_door()->void:
	_DoorAnimation.play("open_door")

func open_petal(index: int)->void:
	if index < 0 or index >= petal_animations.size():
		return
	
	var petal_animation: AnimationPlayer = get_node_or_null(petal_animations[index])
	petal_animation.play(petal_animation_name)
