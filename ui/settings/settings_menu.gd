class_name SettingsMenu
extends Control

signal back_button_pressed

@onready var _master_slider: HSlider = %MasterBusSlider
@onready var _master_enable_check_box: CheckBox = %MasterBusActiveBox
@onready var _master_bus_idx: int = AudioServer.get_bus_index("Master")
@onready var _music_slider: HSlider = %MusicBusSlider
@onready var _music_enable_check_box: CheckBox = %MusicBusActiveBox
@onready var _music_bus_idx: int = AudioServer.get_bus_index("Music")
@onready var _back_button: Button = $BackButton


func _ready() -> void:
	_master_slider.value = AudioServer.get_bus_volume_linear(_master_bus_idx)
	_master_slider.value_changed.connect(_on_master_slider_value_changed)
	_master_enable_check_box.button_pressed = not AudioServer.is_bus_mute(_master_bus_idx)
	_master_enable_check_box.toggled.connect(_on_master_enable_check_box_pressed)
	_music_slider.value = AudioServer.get_bus_volume_linear(_music_bus_idx)
	_music_slider.value_changed.connect(_on_music_slider_value_changed)
	_music_enable_check_box.button_pressed = not AudioServer.is_bus_mute(_music_bus_idx)
	_music_enable_check_box.toggled.connect(_on_music_enable_check_box_pressed)
	_back_button.pressed.connect(back_button_pressed.emit)


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_bus_idx, value)


func _on_master_enable_check_box_pressed(on: bool) -> void:
	AudioServer.set_bus_mute(_master_bus_idx, not on)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_bus_idx, value)


func _on_music_enable_check_box_pressed(on: bool) -> void:
	AudioServer.set_bus_mute(_music_bus_idx, not on)


func show_with_focus():
	_back_button.grab_focus()
	show()
