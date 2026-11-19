class_name HUD
extends Control

@onready var _stopwatch: Label = $StopwatchControl/Stopwatch
@onready var _death_count: Label = $DeathControl/DeathCount
@onready var _level_label: Label = $LevelLabel


static func format_time(elapsed_seconds: int) -> String:
	@warning_ignore("integer_division")
	return "%02d:%02d" % [elapsed_seconds / 60, elapsed_seconds % 60]


func set_stopwatch(elapsed_seconds: int) -> void:
	_stopwatch.text = format_time(elapsed_seconds)


func set_death_count(death_count: int) -> void:
	_death_count.text = str(death_count)


func set_level_label(current: int, total: int) -> void:
	_level_label.text = "%02d/%02d" % [current, total]
