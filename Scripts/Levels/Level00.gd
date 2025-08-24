extends Node

const TITLE_NAME: = "Title"

export(bool) var has_started = false

var title_scene: PackedScene = preload("res://Scenes/UI/Title.tscn")
var title_control: Control

onready var _WorldMusicPlayer: AudioStreamPlayer = $WorldMusicPlayer

func _ready()->void:
	if PlayerManager.player:
		PlayerManager.player.connect("started_moving",self,"_on_Ship_started_moving")


func _enter_tree() -> void:
	UIManager.add_control(TITLE_NAME, title_scene)
	UIManager.add_control_to_layer(TITLE_NAME, "LevelUI")
	title_control = UIManager.controls[TITLE_NAME]

func _exit_tree() -> void:
	UIManager.remove_control(TITLE_NAME)


func _on_Ship_started_moving() -> void:
	if has_started:
		return
	
	has_started = true
	title_control.play()
	_WorldMusicPlayer.play()
