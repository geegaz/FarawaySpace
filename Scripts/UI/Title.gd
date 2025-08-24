extends Control

onready var _Label: Label = $TitleLabel

var tween: SceneTreeTween

func _ready() -> void:
	hide()

func play()->void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_callback(self, "show")
	tween.tween_property(_Label, "percent_visible", 1.0, 0.5)
	tween.tween_interval(1.5)
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	tween.tween_callback(self, "hide")
	
	_Label.percent_visible = 0.0
	modulate.a = 1.0
