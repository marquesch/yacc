extends Node

@onready var _jump_sfx: AudioStreamPlayer = $JumpSFX
@onready var _air_jump_sfx: AudioStreamPlayer = $AirJumpSFX
@onready var _dash_sfx: AudioStreamPlayer = $DashSFX
@onready var _land_sfx: AudioStreamPlayer = $LandSFX
@onready var _footstep: AudioStreamPlayer = $FootstepSFX


func jump() -> void:
	_jump_sfx.play()


func air_jump() -> void:
	_air_jump_sfx.play()


func dash() -> void:
	_dash_sfx.play()


func land() -> void:
	_land_sfx.play()


func footstep() -> void:
	_footstep.play()
