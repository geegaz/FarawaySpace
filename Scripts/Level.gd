class_name Level
extends Node3D

@export var has_gravity: bool
@export var checkpoints: Array[ShipSpawner]
@export var override_player_scene: PackedScene

func _ready() -> void:
	spawn_player(LevelManager.current_checkpoint)

func spawn_player(checkpoint: int)->void:
	var spawner_node: ShipSpawner = checkpoints.get(checkpoint)
	if not spawner_node:
		printerr("Invalid checkpoint %s in %s"%[checkpoint, checkpoints])
		return # Invalid index
	var player_scene: PackedScene = override_player_scene
	if not player_scene:
		player_scene = PlayerManager.player_scene
	
	var player: Ship = player_scene.instantiate()
	player.position = spawner_node.global_position
	player.rotation = spawner_node.global_rotation
	player.gravity_enabled = has_gravity
	add_child(player)
	
	
