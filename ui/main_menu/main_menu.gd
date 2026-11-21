class_name MainMenu
extends Control
## Title screen: Continue, New game (with an overwrite confirmation) and Quit.

signal new_game_requested
signal continue_requested
signal overwrite_save_confirmed
signal quit_requested

@onready var _main_box: Control = $MainBox
@onready var _confirm_box: Control = $ConfirmBox
@onready var _settings_menu: Control = $SettingsMenu
@onready var _continue_button: Button = $MainBox/VBox/ContinueButton
@onready var _new_game_button: Button = $MainBox/VBox/NewGameButton
@onready var _settings_button: Button = $MainBox/VBox/SettingsButton
@onready var _quit_button: Button = $MainBox/VBox/QuitButton
@onready var _yes_button: Button = $ConfirmBox/VBox/Buttons/YesButton
@onready var _no_button: Button = $ConfirmBox/VBox/Buttons/NoButton


func _ready() -> void:
	_new_game_button.pressed.connect(new_game_requested.emit)
	_continue_button.pressed.connect(continue_requested.emit)
	_settings_button.pressed.connect(_show_settings_menu)
	_quit_button.pressed.connect(quit_requested.emit)
	_yes_button.pressed.connect(overwrite_save_confirmed.emit)
	_no_button.pressed.connect(_show_main)
	_settings_menu.back_button_pressed.connect(_show_main)
	_show_main()


func set_continue_button_as(enabled: bool) -> void:
	_continue_button.disabled = not enabled


func show_overwrite_save_confirmation() -> void:
	_main_box.hide()
	_settings_menu.hide()
	_confirm_box.show()
	_no_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _confirm_box.visible and event.is_action_pressed("ui_cancel"):
		_show_main()
		get_viewport().set_input_as_handled()


func _show_main() -> void:
	_confirm_box.hide()
	_settings_menu.hide()
	_main_box.show()
	if _continue_button.disabled:
		_new_game_button.grab_focus()
	else:
		_continue_button.grab_focus()


func _show_settings_menu() -> void:
	_main_box.hide()
	_confirm_box.hide()
	_settings_menu.show_with_focus()
