class_name UI
extends CanvasLayer

signal new_game_requested
signal continue_requested
signal overwrite_save_confirmed
signal quit_requested
signal menu_requested
signal resume_requested

const FADE_TIME := 0.25

@onready var _main_menu: MainMenu = $MainMenu
@onready var _pause_menu: PauseMenu = $PauseMenu
@onready var _end_label: Label = $EndLabel
@onready var _fade: ColorRect = $Fade
@onready var _hud: HUD = $HUD


func _ready() -> void:
	_main_menu.new_game_requested.connect(new_game_requested.emit)
	_main_menu.continue_requested.connect(continue_requested.emit)
	_main_menu.overwrite_save_confirmed.connect(overwrite_save_confirmed.emit)
	_main_menu.quit_requested.connect(quit_requested.emit)
	_pause_menu.menu_requested.connect(menu_requested.emit)
	_pause_menu.resume_requested.connect(resume_requested.emit)


func show_pause_menu() -> void:
	_end_label.hide()
	_main_menu.hide()
	_hud.hide()
	_pause_menu.set_open(true)


func hide_pause_menu() -> void:
	_pause_menu.set_open(false)
	_hud.show()


func show_play() -> void:
	_end_label.hide()
	_pause_menu.hide()
	_main_menu.hide()
	_hud.show()


func show_end(elapsed_seconds: int, deaths: int) -> void:
	_hud.hide()
	_end_label.text = "You did it in %s with %d %s!\nPress any key to go back to the menu" % [
		HUD.format_time(elapsed_seconds), deaths, "death" if deaths == 1 else "deaths"
	]
	_end_label.show()


func show_menu() -> void:
	_end_label.hide()
	_pause_menu.hide()
	_hud.hide()
	_main_menu.show()


func set_level(index: int, total: int) -> void:
	_hud.set_level_label(index + 1, total)


func set_death_count(death_count: int) -> void:
	_hud.set_death_count(death_count)


func set_time(elapsed_seconds: int) -> void:
	_hud.set_stopwatch(elapsed_seconds)


func fade_to(alpha: float, fade_time: float = FADE_TIME) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", alpha, fade_time)
	await tween.finished


func set_continue_enabled(enabled: bool) -> void:
	_main_menu.set_continue_button_as(enabled)


func show_overwrite_save_confirmation() -> void:
	_main_menu.show_overwrite_save_confirmation()
