class_name SettingsMenu
extends Control

signal back_button_pressed

const AUDIO_BUS_NAMES: Array[String] = ["Master", "SFX", "Music"]

@onready var _back_button: Button = $BackButton


func _ready() -> void:
	var idx: int
	var slider: HSlider
	var check_box: CheckBox
	for bus in AUDIO_BUS_NAMES:
		idx = AudioServer.get_bus_index(bus)
		slider = get_node("%%%sBusSlider" % bus)
		check_box = get_node("%%%sBusActiveBox" % bus)
		slider.value = AudioServer.get_bus_volume_linear(idx)
		slider.value_changed.connect(_on_slider_value_changed.bind(idx))
		check_box.button_pressed = not AudioServer.is_bus_mute(idx)
		check_box.toggled.connect(_on_enable_check_box_pressed.bind(idx))

	_back_button.pressed.connect(back_button_pressed.emit)


func _on_slider_value_changed(value: float, bus_idx: int) -> void:
	AudioServer.set_bus_volume_linear(bus_idx, value)


func _on_enable_check_box_pressed(on: bool, bus_idx: int) -> void:
	AudioServer.set_bus_mute(bus_idx, not on)


func show_with_focus() -> void:
	_back_button.grab_focus()
	show()
