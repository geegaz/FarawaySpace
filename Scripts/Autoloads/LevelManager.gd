extends Node

const LEVELS: = {
	"Tutorial": "res://Scenes/Levels/LevelTutorial.tscn",
	"Gym": "res://Scenes/Levels/LevelGym.tscn"
}

var changing_level: bool
var load_additive: bool = false
var first_loading: bool = true

var transition: Transition
var spinner: Spinner

var curren_level: Level
var curren_level_name: String:
	set(value): PlayerSave.set_saved("current_level_name", value)
	get: return PlayerSave.get_saved("current_level_name", "")
var current_checkpoint: int:
	set(value): PlayerSave.set_saved("current_checkpoint", value)
	get: return PlayerSave.get_saved("current_checkpoint", 0)

@onready var tree: SceneTree = get_tree()

func _ready() -> void:
	transition = UIManager.controls.LevelTransition
	transition.hide()
	
	spinner = UIManager.controls.LevelSpinner
	spinner.hide()


func change_level(level_name: String, fade_color: Color = Color.BLACK)->void:
	if changing_level:
		printerr("Already changing level")
		return # Can't change level if already changing
	if level_name not in LEVELS:
		printerr("Unknown level %s"%level_name)
		return # No level provided
	if level_name == curren_level_name and not first_loading:
		printerr("Level is already loaded")
		return # Don't load the current level again
	
	if PlayerManager.playing:
		PlayerManager.player_input.enabled = false
	changing_level = true
	
	if first_loading and not load_additive:
		curren_level = tree.current_scene
	
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
	if curren_level:
		remove_current_level_node_from_scene()
		curren_level = null
	
	# Start loading in the background
	var scene_path: String = LEVELS[level_name] # already checked
	var loaded_scene: = await load_level_threaded(scene_path)
	
	# Add new level
	current_checkpoint = 0 # SAVED
	curren_level_name = level_name # SAVED
	curren_level = loaded_scene.instantiate()
	add_current_level_node_to_scene.call_deferred()
	
	###############
	
	await curren_level.ready
	spinner.hide()
	transition.fade_out()
	await transition.fade_out_finished
	
	first_loading = false
	changing_level = false
	if PlayerManager.playing:
		PlayerManager.player_input.enabled = true


func remove_current_level_node_from_scene(delete: bool = true)->void:
	if load_additive:
		tree.current_scene.remove_child(curren_level)
	else:
		tree.root.remove_child(curren_level)
		tree.current_scene = null
	
	if delete:
		curren_level.queue_free()

func add_current_level_node_to_scene()->void:
	if load_additive:
		# Add the level to the main scene
		tree.current_scene.add_child(curren_level)
	else:
		# Change the scene directly
		tree.root.add_child(curren_level)
		tree.current_scene = curren_level

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
