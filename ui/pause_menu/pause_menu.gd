class_name PauseMenu
extends Control
## Pause overlay. It keeps running while the game is paused (process_mode = Always),
## which is why it can still react to input and un-pause.

## Emitted when the player chooses "Main menu". Main decides what that means.
signal menu_requested
signal resume_requested

@onready var _resume_button: Button = $Center/VBox/ResumeButton
@onready var _menu_button: Button = $Center/VBox/MenuButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(resume_requested.emit)
	_menu_button.pressed.connect(menu_requested.emit)


func _unhandled_input(event: InputEvent) -> void:
	if (visible and event.is_action_pressed("ui_cancel")):
		resume_requested.emit()
		get_viewport().set_input_as_handled()


func set_open(open: bool) -> void:
	visible = open
	if open:
		_resume_button.grab_focus()
