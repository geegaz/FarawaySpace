extends Node

const TITLE_NAME: = "Title"

export(bool) var has_started = false
export var music_player: NodePath
export var title: NodePath

var title_scene: PackedScene = preload("res://Scenes/UI/Title.tscn")
var title_control: Control

onready var _WorldMusicPlayer: AudioStreamPlayer = get_node_or_null(music_player)
onready var _Title: Control = get_node_or_null(title)

func _ready()->void:
	if PlayerManager.player:
		PlayerManager.player.connect("started_moving",self,"_on_Ship_started_moving")

func _on_Ship_started_moving() -> void:
	if has_started:
		return
	
	has_started = true
	if _Title:
		_Title.play()
	if _WorldMusicPlayer:
		_WorldMusicPlayer.play()
