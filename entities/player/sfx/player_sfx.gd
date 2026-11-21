class_name PlayerSFX
extends AudioStreamPlayer

@export_group("Volume")
@export var base_volume_db: float = -20.0
@export var random_volume_offset_db: float = 2.0

@export_group("Pitch")
@export var random_pitch_semitones: float = 6.0


func _ready() -> void:
	volume_db = base_volume_db
	bus = "SFX"

	if stream is AudioStreamRandomizer:
		var randomizer := stream as AudioStreamRandomizer
		randomizer.random_volume_offset_db = random_volume_offset_db
		randomizer.random_pitch_semitones = random_pitch_semitones
