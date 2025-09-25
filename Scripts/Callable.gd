class_name Callable
extends RefCounted

var target_object: Object
var target_method: String
var target_args: Array

func _init(target: Object, method: String, args: = []) -> void:
	target_object = target
	target_method = method
	target_args = args

func do():
	return target_object.callv(target_method, target_args)

func do_deferred():
	return call_deferred("do")
