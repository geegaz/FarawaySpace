extends Node

const SETTINGS_PATH: = "user://settings.cfg"

var save_data: = {}
var save_requested: = false
var file: = ConfigFile.new()

func _init() -> void:
	# Load the save file as soon as PlayerSettings is initialized, so classes 
	# using saved data can use it the moment they're loaded.
	# Create the save file if it doesn't exist yet.
	if FileAccess.file_exists(SETTINGS_PATH):
		load_file()
	else:
		save_file()

func get_setting(category: StringName, setting: StringName, default: Variant = null)->Variant:
	if save_data.has(category):
		return save_data[category].get(setting, default)
	return default

func set_setting(category: StringName, setting: StringName, value: Variant)->bool:
	var target: Dictionary = save_data.get_or_add(category,{})
	var identical: bool = target.has(setting) and target[setting] == value
	var success: = target.set(setting, value)
	if success and not identical:
		request_save() # Only save to disk if the values were different...
	return success # ...but return true even if the values were identical


func load_file()->void:
	save_data = {}
	file.load(SETTINGS_PATH)
	for section in file.get_sections():
		save_data[section] = {}
		for setting in file.get_section_keys(section):
			save_data[section][setting] = file.get_value(section, setting)
	print("Loaded settings with data: ",save_data)

func save_file()->void:
	for section in save_data:
		for setting in save_data[section]:
			file.set_value(section, setting, save_data[section][setting])
	file.save(SETTINGS_PATH)
	print("Saved settings with data: ",save_data)


func request_save()->void:
	if save_requested:
		return
	# Wait for the end of the current frame before saving the file.
	# This should prevent multiple file writes in the same frame.
	save_requested = true
	await get_tree().process_frame
	save_file()
	save_requested = false
