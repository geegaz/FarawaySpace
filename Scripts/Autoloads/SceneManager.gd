extends Node

const MAIN_SCENE_NAME: = "Main"

var level_loader: LevelLoader # Provided by the loader when it enters the tree

var using_main_scene: bool = false
var tree: SceneTree

func _ready() -> void:
	tree = get_tree()
	if tree.current_scene.name == MAIN_SCENE_NAME:
		using_main_scene = true

func change_level(level: LevelData)->void:
	if level_loader:
		# If the LevelLoader is present (only when the game is lanched from the
		# main scene), let it handle the loading
		level_loader.change_level(level)
	else:
		# Otherwise change scene directly
		get_tree().change_scene(level.path)
