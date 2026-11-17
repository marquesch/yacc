extends Node
## Autoload ("InputHints"). Remembers which kind of device was used last, and turns text
## templates like "Jump: {jump}" into wording that matches it ("C / Space", "Cross", ...).

## Emitted when the player switches device, so on-screen hints can refresh.
signal changed

enum Device { KEYBOARD, PLAYSTATION, XBOX }

const TEXTS: Dictionary[Device, Dictionary] = {
	Device.KEYBOARD: {"move": "Arrows / WASD", "jump": "C / Space", "dash": "X / Shift"},
	Device.PLAYSTATION: {"move": "D-pad / Left stick", "jump": "Cross", "dash": "Square"},
	Device.XBOX: {"move": "D-pad / Left stick", "jump": "A", "dash": "X"},
}
## If a controller's name contains one of these it is shown as a PlayStation pad.
const PLAYSTATION_NAMES: Array[String] = [
	"ps3", "ps4", "ps5", "playstation", "dualshock", "dualsense", "sony"
]
const STICK_THRESHOLD := 0.5  ## How far a stick must move to count as "used".

var device := Device.KEYBOARD


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Keep tracking while the game is paused.


func _input(event: InputEvent) -> void:
	var new_device := device
	var key := event as InputEventKey
	var button := event as InputEventJoypadButton
	var motion := event as InputEventJoypadMotion
	if key != null and key.pressed:
		new_device = Device.KEYBOARD
	elif button != null and button.pressed:
		new_device = _pad_type(button.device)
	elif motion != null and absf(motion.axis_value) > STICK_THRESHOLD:
		new_device = _pad_type(motion.device)

	if new_device != device:
		device = new_device
		changed.emit()


## Replaces {move}, {jump} and {dash} in `template` with wording for the current device.
func format(template: String) -> String:
	var result := template
	var texts := TEXTS[device]
	for action: String in texts:
		result = result.replace("{%s}" % action, texts[action])
	return result


## Any pad that isn't recognisably PlayStation is described with Xbox wording
## (this includes e.g. Switch pads).
func _pad_type(device_id: int) -> Device:
	var joy_name := Input.get_joy_name(device_id).to_lower()
	for fragment in PLAYSTATION_NAMES:
		if fragment in joy_name:
			return Device.PLAYSTATION
	return Device.XBOX
