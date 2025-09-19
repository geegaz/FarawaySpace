extends Node

signal loading_completed

var loading_thread: = Thread.new()
var loading_mutex: = Mutex.new()

var changing_level: bool
var current_level: LevelData
var current_level_node: Node

var load_additive: bool = false
var first_loading: bool = true

var transition_scene: = preload("res://Scenes/UI/Transition.tscn")
var transition: Transition
var loading_bar_scene: = preload("res://Scenes/UI/LoadingBar.tscn")
var loading_bar: LoadingBar

onready var tree: SceneTree = get_tree()

func _ready() -> void:
	UIManager.add_control("LevelTransition", transition_scene)
	UIManager.add_control_to_layer("LevelTransition", UIManager.LAYER_GLOBAL)
	transition = UIManager.controls.LevelTransition
	transition.hide()
	
	UIManager.add_control("LevelLoadingBar", loading_bar_scene)
	UIManager.add_control_to_layer("LevelLoadingBar", UIManager.LAYER_GLOBAL)
	loading_bar = UIManager.controls.LevelLoadingBar
	loading_bar.hide()

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
	
	changing_level = true
	
	if first_loading: # When starting the game
		transition.color = Color.black
		transition.show()
		first_loading = false
	else:
		transition.color = level.level_color
		transition.color.a = 0.0
		transition.fade_in()
		yield(transition, "fade_in_finished")
		
		var too_bright: = level.level_color.get_luminance() > 0.5
		loading_bar.modulate = Color.black if too_bright else Color.white
	
	loading_bar.text = "Loading..."
	loading_bar.progress = 0.0
	loading_bar.show()
	
	### LOADING ###
	
	# Remove previous level
	current_level = null
	if current_level_node:
		current_level_node.queue_free()
		current_level_node = null
	
	# Start loading in the background
	loading_thread.start(self, "_load_level_threaded", level.level_scene_path)
	yield(self, "loading_completed")
	var loaded_scene: PackedScene = loading_thread.wait_to_finish()
	
	# Add new level
	current_level = level
	current_level_node = loaded_scene.instance()
	call_deferred("add_current_level_node_to_scene")
	
	###############
	
	loading_bar.progress = 1.0
	loading_bar.text = "Done !"
	yield(tree.create_timer(0.5), "timeout")
	
	loading_bar.hide()
	transition.fade_out()
	yield(transition, "fade_out_finished")
	
	changing_level = false

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
		call_deferred("emit_signal", "loading_completed")
		return ResourceLoader.load(path) as PackedScene
		
	var loader: = ResourceLoader.load_interactive(path, "PackedScene")
	var progress: float
	
	var error: = OK
	while error == OK:
		error = loader.poll()
		progress = float(loader.get_stage()) / (loader.get_stage_count() - 1)
		# Update progress in the main thread
		loading_mutex.lock()
		loading_bar.progress = progress
		loading_mutex.unlock()
	
	call_deferred("emit_signal", "loading_completed")
	
	if error != ERR_FILE_EOF:
		printerr("Failed to load scene %s: "%path, error)
	return loader.get_resource() as PackedScene

