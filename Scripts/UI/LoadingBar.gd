class_name LoadingBar
extends Control

var text: String setget set_text
var progress: float = 0.0 setget set_progress

onready var _Label: Label = $VBoxContainer/Label
onready var _ProgressBar: ProgressBar = $VBoxContainer/ProgressBar

var tween: SceneTreeTween


func set_progress(value: float)->void:
	progress = value
	_ProgressBar.value = progress

func set_text(value: String)->void:
	text = value
	_Label.text = text
