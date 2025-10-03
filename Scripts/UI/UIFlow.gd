@tool
class_name UIFlow
extends Node

signal state_changed(new_state: StringName)

@export var host: Node:
	get: return host if host else self
@export var current_state: StringName

var states: Dictionary[StringName, UIFlowState] = {}
var stack: Array[StringName]

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return # Don't execute in the editor
	setup()

func _validate_property(property: Dictionary) -> void:
	if property.name == "current_state":
		var state_names: = PackedStringArray()
		for child in get_child_states():
			state_names.append(child.name)
		
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(state_names)

func setup()->void:
	for child in get_child_states():
		states[child.name] = child
		child.flow = self
		if child.name != current_state:
			child.status = UIFlowState.STATUS_INACTIVE

func go_back()->void:
	if stack.is_empty():
		printerr("Can't go back, no state in stack")
		return
	
	var state: StringName = stack.pop_back()
	go_to(state, false)

func go_to(state: StringName, use_stack: bool = true)->void:
	var state_none: = state.is_empty()
	if not (state in states or state_none):
		printerr("No state %s in states"%state)
		return
	if state == current_state:
		printerr("Already in state %s"%state)
		return
	
	if not current_state.is_empty():
		if states[current_state].wait_for_exit:
			await states[current_state]._exit_state()
		else:
			states[current_state]._exit_state()
	
	if use_stack:
		stack.push_back(current_state)
	current_state = state
	state_changed.emit(state)
	
	if not state_none:
		states[current_state]._enter_state()

func get_child_states()->Array[UIFlowState]:
	var child_states: Array[UIFlowState]
	for child in host.get_children():
		if child is UIFlowState:
			child_states.append(child)
	return child_states
