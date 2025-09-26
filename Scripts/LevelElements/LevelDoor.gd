class_name LevelDoor
extends Node3D

@export var level: LevelData
@export var locks: Array # (Array, String)
@export var petal_animations: Array[AnimationPlayer]
@export var petal_animation_name: String = "DoorPetal_ARMAction"
@export var door_animation: AnimationPlayer

var open: bool

func _enter_tree() -> void:
	var trigger: LevelTrigger = $LevelTrigger
	trigger.level = level
	
	var door_trigger: Area3D = $DoorTrigger
	door_trigger.body_entered.connect(_on_door_trigger_body_entered)
	door_trigger.body_exited.connect(_on_door_trigger_body_exited)

func _on_door_trigger_body_entered(body: Node)->void:
	if body is Ship:
		open_door()

func _on_door_trigger_body_exited(body: Node)->void:
	if body is Ship:
		pass


func open_door()->void:
	if not open:
		door_animation.play("open_door")
		open = true
