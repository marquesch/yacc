extends Control
## Title screen: Continue, New game (with an overwrite confirmation) and Quit.

const GAME_SCENE := "res://scenes/game.tscn"

@onready var _main_box: Control = $MainBox
@onready var _confirm_box: Control = $ConfirmBox
@onready var _continue_button: Button = $MainBox/VBox/ContinueButton
@onready var _new_game_button: Button = $MainBox/VBox/NewGameButton
@onready var _quit_button: Button = $MainBox/VBox/QuitButton
@onready var _yes_button: Button = $ConfirmBox/VBox/Buttons/YesButton
@onready var _no_button: Button = $ConfirmBox/VBox/Buttons/NoButton


func _ready() -> void:
	_continue_button.disabled = not SaveData.has_save()
	_continue_button.pressed.connect(_on_continue_pressed)
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_quit_button.pressed.connect(get_tree().quit)
	_yes_button.pressed.connect(_start_new_game)
	_no_button.pressed.connect(_show_main)
	_show_main()


func _unhandled_input(event: InputEvent) -> void:
	if _confirm_box.visible and event.is_action_pressed("ui_cancel"):
		_show_main()
		get_viewport().set_input_as_handled()


func _show_main() -> void:
	_confirm_box.hide()
	_main_box.show()
	# Controllers and keyboards need a focused button to navigate from.
	if _continue_button.disabled:
		_new_game_button.grab_focus()
	else:
		_continue_button.grab_focus()


func _on_continue_pressed() -> void:
	if not SaveData.load_game():
		SaveData.new_game()  # The save is unreadable: start fresh rather than guess.
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_new_game_pressed() -> void:
	if not SaveData.has_save():
		_start_new_game()
		return
	# This overwrites progress, so ask first (defaulting to "No").
	_main_box.hide()
	_confirm_box.show()
	_no_button.grab_focus()


func _start_new_game() -> void:
	SaveData.new_game()
	get_tree().change_scene_to_file(GAME_SCENE)
