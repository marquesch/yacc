extends Node

enum State { MENU, PLAYING, TRANSITION, END }

var _state := State.MENU

@onready var _world: World = $World
@onready var _ui: UI = $UI


func _ready() -> void:
	_ui.continue_requested.connect(_on_continue_requested)
	_ui.new_game_requested.connect(_on_new_game_requested)
	_ui.overwrite_save_confirmed.connect(_on_overwrite_save_confirmed)
	_ui.quit_requested.connect(get_tree().quit)
	_ui.resume_requested.connect(_set_paused.bind(false))
	_ui.menu_requested.connect(_on_menu_requested)
	_world.player_died.connect(_on_player_died)
	_world.level_completed.connect(_on_level_completed)
	_show_menu()
	_ui.fade_to(0.0)


func _process(delta: float) -> void:
	if _state == State.PLAYING and not get_tree().paused:
		Progress.time += delta
		_ui.set_time(int(Progress.time))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and _state != State.MENU and _state != State.END:
		Progress.save()


func _unhandled_input(event: InputEvent) -> void:
	if _state == State.PLAYING and event.is_action_pressed("pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
	elif _state == State.END and _is_any_press(event):
		get_viewport().set_input_as_handled()
		_show_menu()
		_ui.fade_to(0.0)


func _on_continue_requested() -> void:
	if not Progress.load_save():
		Progress.reset()
	_start_run()


func _on_new_game_requested() -> void:
	if Progress.has_save():
		_ui.show_overwrite_save_confirmation()
	else:
		_on_overwrite_save_confirmed()


func _on_overwrite_save_confirmed() -> void:
	Progress.reset()
	_start_run()


func _on_menu_requested() -> void:
	_set_paused(false)
	_state = State.TRANSITION
	Progress.save()
	await _ui.fade_to(1.0)
	_show_menu()
	await _ui.fade_to(0.0)


func _on_player_died() -> void:
	Progress.deaths += 1
	_ui.set_death_count(Progress.deaths)


func _on_level_completed() -> void:
	if _state != State.PLAYING:
		return
	_state = State.TRANSITION
	_world.set_active(false)
	await _ui.fade_to(1.0)

	if Progress.level + 1 >= LevelList.LEVELS.size():
		_finish()
		return

	_go_to_level(Progress.level + 1)
	_world.set_active(true)
	await _ui.fade_to(0.0)
	_state = State.PLAYING


func _start_run() -> void:
	if _state != State.MENU:
		return
	_state = State.TRANSITION
	await _ui.fade_to(1.0)

	_ui.set_death_count(Progress.deaths)
	_ui.set_time(int(Progress.time))
	_go_to_level(clampi(Progress.level, 0, LevelList.LEVELS.size() - 1))
	_world.set_active(true)
	_ui.show_play()

	await _ui.fade_to(0.0)
	_state = State.PLAYING


func _go_to_level(index: int) -> void:
	_world.load_level(index)
	_ui.set_level(index, LevelList.LEVELS.size())
	Progress.reach_level(index)


func _finish() -> void:
	_state = State.END
	_world.clear()
	_ui.show_end(int(Progress.time), Progress.deaths)
	Progress.erase()


func _show_menu() -> void:
	_state = State.MENU
	_world.clear()
	_ui.set_continue_enabled(Progress.has_save())
	_ui.show_menu()


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	if paused:
		_ui.show_pause_menu()
	else:
		_ui.hide_pause_menu()


func _is_any_press(event: InputEvent) -> bool:
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
		return event.is_pressed() and not event.is_echo()
	return false
