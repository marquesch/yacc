extends Label
## A label whose text follows the last-used input device. Write the text in `template`
## using {move}, {jump} and {dash}, e.g. "Jump: {jump}".

@export_multiline var template := "":
	set(value):
		template = value
		if is_node_ready():
			_refresh()


func _ready() -> void:
	InputHints.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	text = InputHints.format(template)
