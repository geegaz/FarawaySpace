@abstract
class_name UIFlowState
extends Control

enum {
	STATUS_ACTIVE,
	STATUS_INACTIVE,
	STATUS_ENTERING,
	STATUS_EXITING
}

signal finished_entering
signal finished_exiting

@export var wait_for_exit: bool

var flow: UIFlow
var status: int : set = set_status

func is_current()->bool:
	return flow.current_state == name

func _enter_state()->void:
	status = STATUS_ENTERING
	@warning_ignore("redundant_await")
	await enter_state()
	finished_entering.emit()
	status = STATUS_ACTIVE

func _exit_state()->void:
	status = STATUS_EXITING
	@warning_ignore("redundant_await")
	await exit_state()
	finished_exiting.emit()
	status = STATUS_INACTIVE

@abstract func enter_state()->void
@abstract func exit_state()->void

func set_status(value: int)->void:
	status = value
	match status:
		STATUS_ACTIVE:
			pass
		STATUS_INACTIVE:
			flow.host.remove_child(self)
		STATUS_ENTERING:
			flow.host.add_child(self)
		STATUS_EXITING:
			pass
