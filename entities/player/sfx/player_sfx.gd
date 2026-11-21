extends Node

@onready var _jump_sfx: AudioStreamPlayer = $JumpSFX
@onready var _dash_sfx: AudioStreamPlayer = $DashSFX

func jump() -> void:
	_jump_sfx.play()

func dash() -> void:
	_dash_sfx.play()
