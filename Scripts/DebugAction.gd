class_name DebugAction
extends Node

@export var target: Node
@export var code: String
@export var function: String
@export var args: Array

var debug_active: bool
var matched: int

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_debug"):
		debug_active = event.is_pressed()
		matched = 0
		return
		
	if debug_active and event is InputEventKey:
		if event.pressed:
			if code[matched] == char(event.unicode):
				matched += 1
			else:
				matched = 0
			
		if matched == code.length():
			do_action()
			matched = 0

func do_action()->void:
	if target and target.has_method(function):
		target.callv(function, args)
