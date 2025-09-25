class_name Transition
extends Control

signal fade_in_finished
signal fade_out_finished

var tween: Tween
var tween_callable: Callable

func _ready() -> void:
	hide()

func fade_in(duration: float = 0.5) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	_add_fade_in(duration)

func fade_out(duration: float = 0.5) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	_add_fade_out(duration)
	
func transition(color: Color, callable: Callable, duration: float = 1.0)->void:
	var half_duration: = duration * 0.5
	tween_callable = callable
	
	if tween:
		tween.kill()
	tween = create_tween()
	_add_fade_in(half_duration)
	tween.tween_callback(Callable(tween_callable, "do"))
	_add_fade_out(half_duration)
	
	self.color = color
	self.color.a = 0.0


func _add_fade_in(duration: float) -> void:
	if not tween:
		return
	tween.tween_callback(Callable(self, "show"))
	tween.tween_property(self, "color:a", 1.0, duration)
	tween.tween_callback(Callable(self, "emit_signal").bind("fade_in_finished"))

func _add_fade_out(duration: float) -> void:
	if not tween:
		return
	tween.tween_property(self, "color:a", 0.0, duration)
	tween.tween_callback(Callable(self, "hide"))
	tween.tween_callback(Callable(self, "emit_signal").bind("fade_out_finished"))

