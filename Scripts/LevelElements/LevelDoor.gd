class_name LevelDoor
extends Node3D

@export var level: Resource
@export var locks: Array # (Array, String)
@export var petal_animations: Array # (Array, NodePath)
@export var petal_animation_name: String = "DoorPetal_ARMAction"

var open: bool

@onready var _DoorAnimation: AnimationPlayer = $AnimationPlayer

func _enter_tree() -> void:
	var trigger: LevelTrigger = $LevelTrigger
	trigger.level = level
	
	var door_trigger: Area3D = $DoorTrigger
	door_trigger.connect("body_entered", Callable(self, "_on_door_trigger_body_entered"))
	door_trigger.connect("body_exited", Callable(self, "_on_door_trigger_body_exited"))

func _on_door_trigger_body_entered(body: Node)->void:
	if body is Ship:
		open_door()

func _on_door_trigger_body_exited(body: Node)->void:
	if body is Ship:
		pass


func open_door()->void:
	if not open:
		_DoorAnimation.play("open_door")
		open = true

func open_petal(index: int)->void:
	if index < 0 or index >= petal_animations.size():
		return
	
	var petal_animation: AnimationPlayer = get_node_or_null(petal_animations[index])
	petal_animation.play(petal_animation_name)
