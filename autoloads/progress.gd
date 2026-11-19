extends Node
## Autoload ("Progress"). The current run's progress, saved to user://save.cfg.

const SAVE_PATH := "user://save.cfg"
const SECTION := "progress"

var level := 0
var deaths := 0
var time := 0.0


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Returns false if there is no usable save; the current values are then left untouched.
func load_save() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return false
	var saved_level: Variant = config.get_value(SECTION, "level", 0)
	var saved_deaths: Variant = config.get_value(SECTION, "deaths", 0)
	var saved_time: Variant = config.get_value(SECTION, "time", 0.0)
	if not (saved_level is int and saved_deaths is int and saved_time is float):
		return false
	level = maxi(saved_level, 0)
	deaths = maxi(saved_deaths, 0)
	time = maxf(saved_time, 0.0)
	return true


func save() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, "level", level)
	config.set_value(SECTION, "deaths", deaths)
	config.set_value(SECTION, "time", time)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("Could not write save file: %s" % error_string(error))


func reach_level(index: int) -> void:
	level = index
	save()


func erase() -> void:
	level = 0
	deaths = 0
	time = 0.0
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)


## Starts over, overwriting any existing save.
func reset() -> void:
	level = 0
	deaths = 0
	time = 0.0
	save()
