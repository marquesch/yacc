class_name World
extends Node2D

signal level_completed
signal player_died

var _level: Level

@onready var _level_container: Node2D = $LevelContainer
@onready var _player: Player = $Player


func _on_player_died() -> void:
	_player.respawn(_level.spawn.global_position)
	player_died.emit()


func _on_level_completed() -> void:
	level_completed.emit()


func load_level(index: int) -> void:
	clear()
	_level = (load(LevelList.LEVELS[index]) as PackedScene).instantiate()
	_level_container.add_child(_level)
	_player.show()
	_level.completed.connect(_on_level_completed)

	_player.enter_level(_level)


func set_active(on: bool) -> void:
	_player.set_physics_process(on)


func clear() -> void:
	set_active(false)
	_player.hide()
	if _level == null:
		return

	_level_container.remove_child(_level)
	_level.queue_free()
	_level = null


func _ready() -> void:
	_player.died.connect(_on_player_died)
	if get_parent() == get_tree().root:
		load_level(10)
		set_active(true)
