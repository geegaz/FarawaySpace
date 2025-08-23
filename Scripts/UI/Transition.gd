class_name Transition
extends Control

signal started(transition_name)
signal finished(transition_name)

var tween: SceneTreeTween
var tween_callable: Callable

onready var _Color: ColorRect = $TransitionColor

func transition(transition_name: String, start_color: Color, end_color: Color, callable: Callable, duration: float = 1.0)->void:
	var half_duration: = duration * 0.5
	tween_callable = callable
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(_Color, "color", end_color, duration)
	tween.parallel().tween_property(_Color, "modulate:a", 1.0, half_duration)
	tween.tween_callback(tween_callable, "do")
	tween.tween_property(_Color, "modulate:a", 0.0, half_duration)
	tween.tween_callback(_Color, "hide")
	tween.tween_callback(self, "emit_signal", ["finished", transition_name])
	
	_Color.color = start_color
	_Color.modulate.a = 0.0
	_Color.show()
	emit_signal("started", transition_name)
