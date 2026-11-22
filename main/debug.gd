extends Node

@export var level := 1

@onready var _world: World = $World
@onready var _ui: UI = $UI


func _ready() -> void:
	_ui.set_death_count(0)
	_ui.set_time(0)
	_go_to_level(level - 1)
	_world.set_active(true)
	_ui.show_play()

	await _ui.fade_to(0.0)


func _go_to_level(index: int) -> void:
	_world.load_level(index)
	_ui.set_level(index, LevelList.LEVELS.size())
