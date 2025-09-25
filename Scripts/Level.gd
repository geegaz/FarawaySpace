class_name Level
extends Spatial

export var has_gravity: bool
export var start_checkpoint: int
export(Array, NodePath) var checkpoints: Array
export var override_player_scene: PackedScene

var current_checkpoint: ShipSpawner

func _ready() -> void:
	current_checkpoint = try_get_spawner(start_checkpoint)
	if current_checkpoint:
		spawn_player(current_checkpoint)

func try_get_spawner(index: int)->ShipSpawner:
	var valid_index: bool = start_checkpoint >= 0 and start_checkpoint < checkpoints.size()
	if not valid_index:
		printerr("Invalid index %s in %s"%[start_checkpoint, checkpoints])
		return null # Skip for now too
	
	var checkpoint_path: NodePath = checkpoints[start_checkpoint]
	var checkpoint_node: ShipSpawner = get_node_or_null(checkpoint_path)
	if not checkpoint_node:
		printerr("Couldn't find spawner %s"%checkpoint_path)
		return null
	
	return checkpoint_node

func spawn_player(at: ShipSpawner)->void:
	var player_scene: PackedScene = override_player_scene
	if not player_scene:
		player_scene = PlayerManager.player_scene
	
	var player: Ship = player_scene.instance()
	player.translation = at.global_translation
	player.rotation = at.global_rotation
	player.gravity_enabled = has_gravity
	add_child(player)
	
	
