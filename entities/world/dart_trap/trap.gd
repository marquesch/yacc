class_name DartTrap
extends StaticBody2D

enum Facing { UP, RIGHT, DOWN, LEFT }

const MUZZLE_OFFSET := 16
const DART_SCENE: PackedScene = preload("res://entities/world/dart_trap/dart.tscn")

@export var facing := Facing.UP:
	set(value):
		facing = value
		rotation = facing * PI / 2.0

@export var interval := 2.0
@export var start_delay := 2.0

@export var dart_speed := 100
@export var dart_lifetime := 5


func _ready() -> void:
	rotation = facing * PI / 2.0
	if Engine.is_editor_hint():
		return

	if start_delay > 0.0:
		await get_tree().create_timer(start_delay, false).timeout

	var timer := Timer.new()
	timer.wait_time = interval
	timer.timeout.connect(_shoot_dart)
	add_child(timer)
	timer.start()


func _shoot_dart() -> void:
	var dart := DART_SCENE.instantiate()
	dart.speed = dart_speed
	dart.lifetime = dart_lifetime
	dart.rotation = rotation
	dart.global_position = global_position + Vector2.UP.rotated(rotation) * MUZZLE_OFFSET

	get_parent().add_child(dart)
