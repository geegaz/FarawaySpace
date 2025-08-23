extends Node

var level_loader: LevelLoader # Provided by the loader when it enters the tree

func change_level(level: LevelData)->void:
	if level_loader:
		# If the LevelLoader is present (only when the game is lanched from the
		# main scene), let it handle the loading
		level_loader.change_level(level)
	else:
		# Otherwise change scene directly
		get_tree().change_scene(level.path)
