class_name LevelLoader
extends Node

export var start_level: Resource

export var transition_color: Color

onready var _Transition: Transition = UIManager.controls[UIManager.TRANSITION_NAME]

var current_level: Node

var changing_level: bool
var finished_loading: bool
var loaded_level: PackedScene

onready var tree: = get_tree()

func _ready() -> void:
	SceneManager.level_loader = self
	if start_level:
		change_level(start_level)

func change_level(level: LevelData)->void:
	if changing_level:
		return # Already changing level
	
	changing_level = true # Start the loading process
	if _Transition:
		# Steps:
		# - Fade in the transition
		# - Load level in the background
		# - Remove the previous level from the tree
		# - Add the new level to the tree
		# - Fade out the transition
		_Transition.set_color(transition_color)
		_load_level_async(level.path) # Start loading while setting up the transition
		if current_level: # Only fade in if there was a level loaded previously
			_Transition.fade_in()
			yield(_Transition, "fade_in_finished")
		else: # Start the transition from the fade out directly
			_Transition.set_alpha(1.0) # Force alpha
			_Transition.set_visible(true) # Force visible
		
		var await = await_loading()
		if await is GDScriptFunctionState:
			yield(await, "completed")
		
		_change_level()
		_Transition.fade_out()
#		yield(_Transition, "fade_out_finished")
	else:
		_load_level_async(level.path)
		var await = await_loading()
		if await is GDScriptFunctionState:
			yield(await, "completed")
		_change_level()
	
	changing_level = false # Free the process


func _load_level_async(level_path: String) -> void:
	if ResourceLoader.has_cached(level_path):
		loaded_level = ResourceLoader.load(level_path)
		finished_loading = true
		return # Skip async loading if the level was cached
	
	var resource_loader: = ResourceLoader.load_interactive(level_path, "PackedScene")
	var progress: float = 0.0
	loaded_level = null
	
	if _Transition:
		_Transition.set_progress_visible(true)
	
	var error: = OK
	while error == OK:
		error = resource_loader.poll()
		progress = float(resource_loader.get_stage()) / (resource_loader.get_stage_count() - 1)
		if _Transition:
			_Transition.set_progress_value(progress)
		yield(tree, "idle_frame") # Wait for the next frame
	
	if _Transition:
		_Transition.set_progress_visible(false)
	
	if error == ERR_FILE_EOF:
		# Loading succeeded
		loaded_level = resource_loader.get_resource()
	else:
		# Loading failed
		printerr("Failed to load scene %s: "%level_path, error)
	
	finished_loading = true

func _change_level()->void:
	if not loaded_level:
		return # Can't change to an invalid scene
	
	if current_level:
		current_level.queue_free()
	current_level = loaded_level.instance()
	tree.current_scene.add_child(current_level)

func await_loading()->void:
	while not finished_loading:
		yield(tree, "idle_frame") # Wait for the next frame
