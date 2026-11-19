class_name Level extends Node2D
## Root of every level scene.
##
## A level scene contains platforms, a `Spawn` (Marker2D) where the player starts and an
## `Exit` (Area2D) that completes the level. The player is NOT part of the level: World
## owns the player and carries it from level to level.

## Emitted when the player touches the exit.
signal completed

## Playable area in pixels, from the origin. Used for camera limits and the fall limit.
@export var size := Vector2i(320, 180)

@onready var spawn: Marker2D = $Spawn
@onready var exit: Area2D = $Exit


func _ready() -> void:
	exit.body_entered.connect(_on_exit_body_entered)


func _on_exit_body_entered(body: Node2D) -> void:
	if body is Player:
		completed.emit()
