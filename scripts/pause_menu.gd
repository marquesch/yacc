class_name PauseMenu
extends Control
## Pause overlay. It keeps running while the game is paused (process_mode = Always),
## which is why it can still react to input and un-pause.

## Emitted when the player chooses "Main menu". The Game decides what that means.
signal menu_requested

@onready var _resume_button: Button = $Center/VBox/ResumeButton
@onready var _menu_button: Button = $Center/VBox/MenuButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(_set_open.bind(false))
	_menu_button.pressed.connect(_on_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (visible and event.is_action_pressed("ui_cancel")):
		_set_open(not visible)
		get_viewport().set_input_as_handled()


func _set_open(open: bool) -> void:
	visible = open
	get_tree().paused = open
	if open:
		_resume_button.grab_focus()


func _on_menu_pressed() -> void:
	menu_requested.emit()
