class_name LevelDoor
extends Node3D

@export var level: LevelData
@export var required_keys: PackedStringArray
@export var door_animation: AnimationPlayer

var available_keys: PackedStringArray:
	set(value): PlayerSave.set_saved("available_keys", value)
	get: return PlayerSave.get_saved("available_keys", [])
var used_keys: PackedStringArray:
	set(value): PlayerSave.set_saved("used_keys", value)
	get: return PlayerSave.get_saved("used_keys", [])

var open: bool

func _enter_tree() -> void:
	var trigger: LevelTrigger = $LevelTrigger
	trigger.level = level
	
	var door_trigger: Area3D = $DoorTrigger
	door_trigger.body_entered.connect(_on_door_trigger_body_entered)
	door_trigger.body_exited.connect(_on_door_trigger_body_exited)

func _ready() -> void:
	var unlocked: = true
	for key in required_keys:
		if key not in used_keys:
			unlocked = false
			break
	
	if unlocked:
		open = true
		door_animation.play("open_door")
		door_animation.seek(3.0) # Go to the end of the animation

func _on_door_trigger_body_entered(body: Node)->void:
	if body is Ship:
		open_door()

func _on_door_trigger_body_exited(body: Node)->void:
	if body is Ship:
		pass


func open_door()->void:
	if open:
		return
	
	# Get a reference to the key lists to avoid
	# calling the getter on each iteration
	var a_keys: = available_keys
	var u_keys: = used_keys
	
	if a_keys.is_empty():
		# TODO: Feedback for the missing keys
		return # No key available, so no need to check them
	
	var required_keys_amount: = required_keys.size()
	for key in required_keys:
		if key in u_keys:
			required_keys_amount -= 1
		elif key in a_keys:
			a_keys.erase(key)
			u_keys.append(key)
			required_keys_amount -= 1
			# TODO: Feedback for the used keys that were removed
	
	# Apply the changed keys to the save file
	available_keys = a_keys
	used_keys = u_keys
	
	if required_keys_amount > 0:
		# TODO: Feedback for the missing keys
		return # Not enough keys
	
	open = true
	door_animation.play("open_door")


func debug_force_open()->void:
	open = true
	door_animation.play("open_door")

func debug_add_keys()->void:
	var a_keys: = available_keys
	var u_keys: = used_keys
	
	for key in required_keys:
		if key in a_keys or key in u_keys:
			continue
		a_keys.append(key)
	
	available_keys = a_keys
	
