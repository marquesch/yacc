extends CanvasLayer

@onready var stopwatch: Label = $Stopwatch
@onready var death_count: Label = $DeathCount


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_stopwatch(elapsed_seconds: int) -> void:
	var minutes: int = elapsed_seconds / 60
	var seconds: int = elapsed_seconds % 60

	stopwatch.text = "%02d:%02d" % [minutes, seconds]


func update_death_count(deaths: int) -> void:
	death_count.text = str(deaths)
