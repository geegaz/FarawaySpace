extends Node

enum {
	SAVE_TYPE_BINARY,
	SAVE_TYPE_JSON
}

const SAVE_PATHS: = {
	SAVE_TYPE_BINARY: "user://save.dat",
	SAVE_TYPE_JSON: "user://save.json"
}

var save_data: = {}
var save_type: = SAVE_TYPE_JSON
var save_path: String : 
	get : return SAVE_PATHS[save_type]

var save_requested: = false

func _init() -> void:
	# Load the save file as soon as PlayerSave is initialized, so classes 
	# using saved data can use it the moment they're loaded.
	# Create the save file if it doesn't exist yet.
	if FileAccess.file_exists(save_path):
		load_file()
	else:
		save_file()

func get_saved(value_name: StringName, default: Variant = null)->Variant:
	return save_data.get(value_name, default)

func set_saved(value_name: StringName, value: Variant) -> bool:
	var identical: bool = save_data.has(value_name) and save_data[value_name] == value
	var success: bool = save_data.set(value_name, value)
	if success and not identical:
		request_save() # Only save to disk if the values were different...
	return success # ...but return true even if the values were identical


func save_file()->void:
	var file: = FileAccess.open(save_path, FileAccess.WRITE)
	match save_type:
		SAVE_TYPE_BINARY:
			file.store_var(save_data)
		SAVE_TYPE_JSON:
			var json_string: = JSON.stringify(save_data, "\t")
			file.store_string(json_string)
	print("Saved save file with data: ",save_data)

func load_file()->void:
	var file: = FileAccess.open(save_path, FileAccess.READ)
	match save_type:
		SAVE_TYPE_BINARY:
			save_data = file.get_var()
		SAVE_TYPE_JSON:
			var json_string: = file.get_as_text()
			save_data = JSON.parse_string(json_string)
	print("Loaded save file with data: ",save_data)

func request_save()->void:
	if save_requested:
		return
	# Wait for the end of the current frame before saving the file.
	# This should prevent multiple file writes in the same frame.
	save_requested = true
	await get_tree().process_frame
	save_file()
	save_requested = false
