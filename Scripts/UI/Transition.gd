class_name Transition
extends Control

signal fade_in_finished
signal fade_out_finished

var tween: SceneTreeTween
var tween_callable: Callable

onready var _Color: ColorRect = $TransitionColor
onready var _Progress: ProgressBar = $TransitionColor/Progress


func _ready() -> void:
	hide()

func set_visible(value: bool)->void:
	self.visible = value

func set_alpha(alpha: float)->void:
	self.modulate.a = alpha

func set_color(color: Color)->void:
	_Color.color = color

func set_progress_visible(value: bool)->void:
	_Progress.visible = value

func set_progress_value(value: float)->void:
	_Progress.value = value

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
	tween.tween_callback(tween_callable, "do")
	_add_fade_out(half_duration)
	
	_Color.color = color
	self.modulate.a = 0.0


func _add_fade_in(duration: float) -> void:
	if not tween:
		return
	tween.tween_callback(self, "show")
	tween.tween_property(self, "modulate:a", 1.0, duration)
	tween.tween_callback(self, "emit_signal", ["fade_in_finished"])

func _add_fade_out(duration: float) -> void:
	if not tween:
		return
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(self, "hide")
	tween.tween_callback(self, "emit_signal", ["fade_out_finished"])

