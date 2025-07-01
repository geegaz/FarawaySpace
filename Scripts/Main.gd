extends Node

export(bool) var has_started = false

onready var _Title: Control = $UI/Title
onready var _Ship: Spatial = $Ship
onready var _WorldAnimationPlayer: AnimationPlayer = $WorldAnimationPlayer
onready var _WorldMusicPlayer: AudioStreamPlayer = $WorldMusicPlayer

func _ready()->void:
	_Ship.connect("started_moving",self,"_on_Ship_started_moving")

func _on_Ship_started_moving() -> void:
	if has_started:
		return
	
	has_started = true
	_WorldAnimationPlayer.play("title")
	_WorldMusicPlayer.play()
