@abstract
class_name UIFlowState
extends Control

var flow: UIFlow

func is_current()->bool:
	return flow.is_current_state(name)

@abstract func _enter_state()->void
@abstract func _exit_state()->void
