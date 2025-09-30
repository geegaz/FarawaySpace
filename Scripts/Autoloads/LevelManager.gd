extends Node

const LEVELS: = {
	"Tutorial": "res://Scenes/Levels/LevelTutorial.tscn",
	"Level 0": "res://Scenes/Levels/Level00.tscn"
}

var changing_level: bool
var load_additive: bool = false
var first_loading: bool = true

var transition: Transition
var spinner: Spinner

var current_level_node: Node
var current_level: String:
	set(value): PlayerSave.set_saved("current_level", value)
	get: return PlayerSave.get_saved("current_level", "")
var current_checkpoint: int:
	set(value): PlayerSave.set_saved("current_checkpoint", value)
	get: return PlayerSave.get_saved("current_checkpoint", 0)

@onready var tree: SceneTree = get_tree()

func _ready() -> void:
	transition = UIManager.controls.LevelTransition
	transition.hide()
	
	spinner = UIManager.controls.LevelSpinner
	spinner.hide()


func change_level(level: String, fade_color: Color = Color.BLACK)->void:
	if changing_level:
		printerr("Already changing level")
		return # Can't change level if already changing
	if level not in LEVELS:
		printerr("Unknown level %s"%level)
		return # No level provided
	if level == current_level and not first_loading:
		printerr("Level is already loaded")
		return # Don't load the current level again
	
	PlayerManager.player_input.enabled = false
	changing_level = true
	
	if first_loading and not load_additive:
		current_level_node = tree.current_scene
	
	transition.color = fade_color
	if first_loading and load_additive: # When starting the game
		transition.show()
	else:
		transition.color.a = 0.0
		transition.fade_in()
		await transition.fade_in_finished
		
	var bright: bool = transition.color.get_luminance() > 0.5
	spinner.modulate = Color.BLACK if bright else Color.WHITE
	spinner.show()
	
	### LOADING ###
	
	# Remove previous level
	if current_level_node:
		remove_current_level_node_from_scene()
		current_level_node = null
	
	# Start loading in the background
	var scene_path: String = LEVELS[level] # already checked
	var loaded_scene: = await load_level_threaded(scene_path)
	
	# Add new level
	current_level = level # SAVED
	current_checkpoint = 0 # SAVED
	current_level_node = loaded_scene.instantiate()
	add_current_level_node_to_scene.call_deferred()
	
	###############
	
	spinner.hide()
	transition.fade_out()
	await transition.fade_out_finished
	
	first_loading = false
	changing_level = false
	PlayerManager.player_input.enabled = true


func remove_current_level_node_from_scene(delete: bool = true)->void:
	if load_additive:
		tree.current_scene.remove_child(current_level_node)
	else:
		tree.root.remove_child(current_level_node)
		tree.current_scene = null
	
	if delete:
		current_level_node.queue_free()

func add_current_level_node_to_scene()->void:
	if load_additive:
		# Add the level to the main scene
		tree.current_scene.add_child(current_level_node)
	else:
		# Change the scene directly
		tree.root.add_child(current_level_node)
		tree.current_scene = current_level_node

func load_level_threaded(path: String)->PackedScene:
	if ResourceLoader.has_cached(path):
		return ResourceLoader.load(path) as PackedScene
		
	var error: = ResourceLoader.load_threaded_request(path, "PackedScene")
	if error != OK:
		printerr("Failed to load scene %s"%path, error)
		return null
	
	var status: = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		status = ResourceLoader.load_threaded_get_status(path)
		await tree.process_frame
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	printerr("Failed to load scene %s"%path, error)
	return null
