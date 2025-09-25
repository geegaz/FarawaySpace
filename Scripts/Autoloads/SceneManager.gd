extends Node

signal loading_completed

var loading_thread: = Thread.new()
var loading_mutex: = Mutex.new()

var changing_level: bool
var current_level: LevelData
var current_level_node: Node

var load_additive: bool = false
var first_loading: bool = true

var transition: Transition
var spinner: Spinner

onready var tree: SceneTree = get_tree()

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
	
	var dir: = Directory.new()
	if not dir.file_exists(level.level_scene_path):
		printerr("Level scene path is invalid")
		return # Can't load an invalid path
	
	PlayerManager.player_input.enabled = false
	changing_level = true
	
	if load_additive and first_loading: # When starting the game
		transition.color = Color.black
		transition.show()
		first_loading = false
	else:
		transition.color = level.level_color
		transition.color.a = 0.0
		transition.fade_in()
		yield(transition, "fade_in_finished")
		
	var bright: bool = transition.color.get_luminance() > 0.5
	spinner.modulate = Color.black if bright else Color.white
	spinner.show()
	
	### LOADING ###
	
	# Remove previous level
	if current_level_node:
		remove_current_level_node_from_scene()
		current_level_node = null
	current_level = null
	
	# Start loading in the background
	loading_thread.start(self, "_load_level_threaded", level.level_scene_path)
	yield(self, "loading_completed")
	var loaded_scene: PackedScene = loading_thread.wait_to_finish()
	
	# Add new level
	current_level = level
	current_level_node = loaded_scene.instance()
	call_deferred("add_current_level_node_to_scene")
	
	###############
	
	yield(current_level_node, "ready")
	spinner.hide()
	transition.fade_out()
	yield(transition, "fade_out_finished")
	
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
		
	var loader: = ResourceLoader.load_interactive(path, "PackedScene")
	var error: = OK
	while error == OK:
		OS.delay_msec(5)
		error = loader.poll()
	
	call_deferred("emit_signal", "loading_completed")
	
	if error != ERR_FILE_EOF:
		printerr("Failed to load scene %s"%path, error)
	return loader.get_resource() as PackedScene
	

