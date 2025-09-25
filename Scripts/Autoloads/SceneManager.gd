extends Node

var changing_level: bool
var current_level: LevelData
var current_level_node: Node

var load_additive: bool = false
var first_loading: bool = true

var transition: Transition
var spinner: Spinner

@onready var tree: SceneTree = get_tree()

func _ready() -> void:
	transition = UIManager.controls.LevelTransition
	transition.hide()
	
	spinner = UIManager.controls.LevelSpinner
	spinner.hide()

func change_level(level: LevelData)->void:
	if changing_level:
		printerr("Already changing level")
		return # Can't change level if already changing
	if not level:
		printerr("No LevelData provided")
		return # No level provided
	if level == current_level:
		printerr("Level is already loaded")
		return # Don't load the current level again
	
	if not FileAccess.file_exists(level.level_scene_path):
		printerr("Level scene path is invalid")
		return # Can't load an invalid path
	
	PlayerManager.player_input.enabled = false
	changing_level = true
	
	if load_additive and first_loading: # When starting the game
		transition.color = Color.BLACK
		transition.show()
		first_loading = false
	else:
		transition.color = level.level_color
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
	current_level = null
	
	# Start loading in the background
	var loaded_scene: = await _load_level_threaded(level.level_scene_path)
	
	# Add new level
	current_level = level
	current_level_node = loaded_scene.instantiate()
	call_deferred("add_current_level_node_to_scene")
	
	###############
	
	await current_level_node.ready
	spinner.hide()
	transition.fade_out()
	await transition.fade_out_finished
	
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


func _load_level_threaded(path: String)->PackedScene:
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
