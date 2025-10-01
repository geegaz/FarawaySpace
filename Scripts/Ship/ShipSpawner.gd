class_name ShipSpawner
extends Node3D

@export var spawner_camera: PhantomCamera3D

func focus_camera()->void:
	if not spawner_camera:
		return
	spawner_camera.priority = 10
	spawner_camera.teleport_position()

func unfocus_camera()->void:
	if not spawner_camera:
		return
	spawner_camera.priority = 0


func spawn_player(parent: Node3D, player_scene: PackedScene = null)->Ship:
	if not player_scene:
		printerr("No player scene provided")
		return null
	
	var player: = player_scene.instantiate()
	player.position = global_position
	player.rotation = global_rotation
	parent.add_child(player)
	
	return player
