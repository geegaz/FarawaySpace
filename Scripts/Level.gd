class_name Level
extends Node3D

@export var has_gravity: bool
@export var start_checkpoint: int
@export var checkpoints: Array[ShipSpawner]
@export var override_player_scene: PackedScene

var current_checkpoint: ShipSpawner

func _ready() -> void:
	current_checkpoint = checkpoints.get(start_checkpoint)
	if current_checkpoint:
		spawn_player(current_checkpoint)

func spawn_player(at: ShipSpawner)->void:
	var player_scene: PackedScene = override_player_scene
	if not player_scene:
		player_scene = PlayerManager.player_scene
	
	var player: Ship = player_scene.instantiate()
	player.position = at.global_position
	player.rotation = at.global_rotation
	player.gravity_enabled = has_gravity
	add_child(player)
	
	
