extends Node

const levels: = {
	"Tutorial": {
		"path": "res://Scenes/Levels/LevelTutorial.tscn"
	},
	"Level 0": {
		"path": "res://Scenes/Levels/Level00.tscn"
	}
}

var changing_level: bool
var current_level_name: String
var current_level_node: Node

var load_additive: bool = false
var first_loading: bool = true

onready var tree: SceneTree = get_tree()
onready var transition: Transition = UIManager.controls[UIManager.TRANSITION_NAME]

func change_level(level_name: String)->void:
	if level_name == current_level_name:
		return # Don't load the current level
	if changing_level:
		return # Can't change level if already changing
	var level = levels.get(level_name)
	if not level:
		return # Level name is not in the dictionary
	
	changing_level = true
	PlayerManager.player.enabled = false
	
	# Steps:
	# - Fade in the transition
	# - Load level in the background
	# - Remove the previous level from the tree
	# - Add the new level to the tree
	# - Fade out the transition
	if first_loading: # When starting the game
		transition.set_alpha(1.0)
		transition.set_visible(true)
		first_loading = false
	else:
		transition.fade_in()
		yield(transition, "fade_in_finished")
	
	transition.set_progress_visible(true)
	transition.set_progress_value(0.0)
	
	var loaded_scene = _load_level_async(level.path)
	if loaded_scene is GDScriptFunctionState:
		loaded_scene = yield(loaded_scene, "completed")
	
	if load_additive:
		# Add the level to the main scene
		if current_level_node:
			current_level_node.queue_free()
		current_level_node = loaded_scene.instance()
		tree.current_scene.add_child(current_level_node)
	else:
		# Change the scene directly
		tree.change_scene_to(loaded_scene)
		current_level_node = tree.current_scene
	current_level_name = level_name
	
	transition.set_progress_value(1.0)
	transition.set_progress_visible(false)
	
	transition.fade_out()
	yield(transition, "fade_out_finished")
	
	changing_level = false
	PlayerManager.player.enabled = true


func _load_level_async(path: String)->PackedScene:
	if ResourceLoader.has_cached(path):
		# Skip interactive loading if the level was cached
		return ResourceLoader.load(path)
	
	var loader: = ResourceLoader.load_interactive(path, "PackedScene")
	var error: = OK
	while error == OK:
		error = loader.poll()
		transition.set_progress_value(
			float(loader.get_stage()) / (loader.get_stage_count() - 1))
		yield(tree, "idle_frame")
	
	if error == ERR_FILE_EOF: # Loading succeeded
		return loader.get_resource()
	
	# Otherwise, loading failed
	printerr("Failed to load scene %s: "%path, error)
	return null
	
