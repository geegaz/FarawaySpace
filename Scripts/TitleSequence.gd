extends Node

const TITLE_NAME: = "Title"

export(bool) var has_started = false
export var music_player: NodePath

var title_scene: PackedScene = preload("res://Scenes/UI/Title.tscn")
var title_control: Control

onready var _WorldMusicPlayer: AudioStreamPlayer = get_node_or_null(music_player)

func _enter_tree() -> void:
	UIManager.add_control(TITLE_NAME, title_scene)
	UIManager.add_control_to_layer(TITLE_NAME, "LevelUI")

func _exit_tree() -> void:
	UIManager.remove_control(TITLE_NAME)

func _ready()->void:
	if PlayerManager.player:
		PlayerManager.player.connect("started_moving",self,"_on_Ship_started_moving")

func _on_Ship_started_moving() -> void:
	if has_started:
		return
	
	has_started = true
	UIManager.controls[TITLE_NAME].play()
	if _WorldMusicPlayer:
		_WorldMusicPlayer.play()
