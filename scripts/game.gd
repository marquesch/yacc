class_name Game
extends Node
## Runs a play session: loads levels one after another, respawns the player when they
## fall, fades between levels and saves progress.
##
## Scene layout (see game.tscn): a container for the current level, the player (which
## lives outside the level so it survives level changes), and a UI layer.

const MENU_SCENE := "res://scenes/main_menu.tscn"
const FADE_TIME := 0.25
const END_SCREEN_TIME := 3.0

var _level_index := 0
var _level: Level
var _is_transitioning := false

@onready var _level_container: Node2D = $LevelContainer
@onready var _player: Player = $Player
@onready var _fade: ColorRect = $UI/Fade
@onready var _level_label: Label = $UI/LevelLabel
@onready var _end_label: Label = $UI/EndLabel
@onready var _pause_menu: PauseMenu = $UI/PauseMenu


func _ready() -> void:
	_player.died.connect(_on_player_died)
	_pause_menu.menu_requested.connect(_on_menu_requested)
	_fade.modulate.a = 1.0  # Start black, then fade in.
	_load_level(clampi(SaveData.level, 0, LevelList.LEVELS.size() - 1))
	_fade_to(0.0)


func _load_level(index: int) -> void:
	if _level != null:
		_level_container.remove_child(_level)
		_level.queue_free()
	_level_index = index
	_level = (load(LevelList.LEVELS[index]) as PackedScene).instantiate()
	_level_container.add_child(_level)
	_level.completed.connect(_on_level_completed)

	_player.enter_level(_level)
	_level_label.text = "%d / %d" % [index + 1, LevelList.LEVELS.size()]

	SaveData.level = index
	SaveData.save_game()


func _on_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_player_died() -> void:
	# Back to the start of the current level.
	_player.respawn(_level.spawn.global_position)


func _on_level_completed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_player.set_physics_process(false)
	await _fade_to(1.0)

	if _level_index + 1 >= LevelList.LEVELS.size():
		# The flag stays set on purpose: the game is over, there is nothing left to play.
		_finish()
		return

	_load_level(_level_index + 1)
	_player.set_physics_process(true)
	await _fade_to(0.0)
	_is_transitioning = false


func _finish() -> void:
	# Game beaten: the next "Continue" starts again from the first level.
	SaveData.level = 0
	SaveData.save_game()
	_end_label.show()
	# A tween (unlike a SceneTreeTimer) stops while paused and dies with this scene.
	var tween := create_tween()
	tween.tween_interval(END_SCREEN_TIME)
	await tween.finished
	get_tree().change_scene_to_file(MENU_SCENE)


## Returns when the screen fade has reached `alpha` (1 = black, 0 = clear).
func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", alpha, FADE_TIME)
	await tween.finished
