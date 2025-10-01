class_name Level
extends Node3D

@export var has_gravity: bool
@export var checkpoints: Array[ShipSpawner]
@export var player_scene_override: PackedScene

func _enter_tree() -> void:
	PlayerManager.started_playing.connect(_on_player_manager_started_playing)
	PlayerManager.stopped_playing.connect(_on_player_manager_stopped_playing)

func _exit_tree() -> void:
	PlayerManager.started_playing.disconnect(_on_player_manager_started_playing)
	PlayerManager.stopped_playing.disconnect(_on_player_manager_stopped_playing)

func _ready() -> void:
	var spawner: = get_spawner(LevelManager.current_checkpoint)
	var player_scene: = PlayerManager.player_scene
	if player_scene_override:
		player_scene = player_scene_override
	var player: = spawner.spawn_player(self, player_scene)
	if player:
		player.gravity_enabled = has_gravity
	
	if not PlayerManager.playing:
		spawner.focus_camera()

func get_spawner(checkpoint: int)->ShipSpawner:
	var spawner_index: int = clampi(checkpoint, 0, checkpoints.size() - 1)
	return checkpoints.get(spawner_index)


func _on_player_manager_started_playing()->void:
	var spawner: = get_spawner(LevelManager.current_checkpoint)
	spawner.unfocus_camera()

func _on_player_manager_stopped_playing()->void:
	var spawner: = get_spawner(LevelManager.current_checkpoint)
	spawner.focus_camera()
