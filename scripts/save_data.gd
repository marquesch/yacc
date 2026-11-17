extends Node
## Autoload ("SaveData"). The player's saved progress, stored as JSON in user://save.json.
##
## `user://` is a per-user folder Godot picks for us (on Linux:
## ~/.local/share/godot/app_userdata/<project name>/), so saves survive game updates.

const SAVE_PATH := "user://save.json"
## Written into the file so future versions can migrate old saves. Not read yet.
const VERSION := 1

## Index of the level to start from.
var level := 0


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Loads the save file into `level`. Returns false if there is no usable save.
func load_game() -> bool:
	if not has_save():
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var saved_level: Variant = parsed.get("level", 0)
	# JSON has only one number type, so a saved integer comes back as a float.
	if typeof(saved_level) != TYPE_INT and typeof(saved_level) != TYPE_FLOAT:
		return false
	level = maxi(int(saved_level), 0)
	return true


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write save file: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify({"version": VERSION, "level": level}))


## Starts over, overwriting any existing save.
func new_game() -> void:
	level = 0
	save_game()
