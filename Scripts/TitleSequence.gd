extends Node

const TITLE_NAME: = "Title"

@export var has_started: bool = false
@export var music_player: AudioStreamPlayer
@export var title: Control

func _ready()->void:
	if PlayerManager.player:
		PlayerManager.player.connect("started_moving", Callable(self, "_on_Ship_started_moving"))

func _on_Ship_started_moving() -> void:
	if has_started:
		return
	
	has_started = true
	if title:
		title.play()
	if music_player:
		music_player.play()
