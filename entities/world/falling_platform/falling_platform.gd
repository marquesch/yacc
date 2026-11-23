@tool
class_name FallingPlatform
extends Platform

@export var gravity := 900.0
@export var delay := 0.5
@export var fall_time := 3

var _velocity := 0.0
var _falling := false
var _triggered := false
var _waiting_to_spawn := false

@onready var trigger_area: Area2D = $TriggerArea
@onready var trigger_shape_node: CollisionShape2D = $TriggerArea/Shape
@onready var _spawn_area: Area2D = $SpawnArea
@onready var _spawn_area_shape_node: CollisionShape2D = $SpawnArea/Shape


func _init() -> void:
	color = Color.RED


func _physics_process(delta: float) -> void:
	if not _falling:
		return
	_velocity += gravity * delta
	position.y += _velocity * delta


func _rebuild() -> void:
	super()

	if _spawn_area == null:
		_spawn_area = Area2D.new()
		_spawn_area.name = "SpawnArea"
		_spawn_area.top_level = true
		add_child(_spawn_area)

	if _spawn_area_shape_node == null:
		_spawn_area_shape_node = CollisionShape2D.new()
		_spawn_area_shape_node.name = "CollisionShape"
		_spawn_area.add_child(_spawn_area_shape_node)

	var spawn_shape := RectangleShape2D.new()
	spawn_shape.size = size
	_spawn_area_shape_node.shape = spawn_shape

	if trigger_area == null:
		trigger_area = Area2D.new()
		trigger_area.name = "TriggerArea"
		add_child(trigger_area)

	if trigger_shape_node == null:
		trigger_shape_node = CollisionShape2D.new()
		trigger_area.add_child(trigger_shape_node)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(size.x, 2.0)
	trigger_shape_node.shape = shape
	trigger_shape_node.position = Vector2(0.0, -size.y / 2.0)


func _ready() -> void:
	super()
	_spawn_area.global_position = global_position
	_spawn_area.body_exited.connect(_on_body_exited)
	trigger_area.body_entered.connect(_on_body_entered)


func _on_body_exited(body: Node2D) -> void:
	if body is Player and _waiting_to_spawn:
		_waiting_to_spawn = false
		_respawn()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not _triggered:
		_triggered = true
		get_tree().create_timer(delay, false).timeout.connect(_on_triggered)


func _on_triggered() -> void:
	_falling = true
	get_tree().create_timer(fall_time, false).timeout.connect(_respawn)


func _respawn() -> void:
	if _player_in_respawn_area():
		_waiting_to_spawn = true
		return
	_velocity = 0
	_triggered = false
	_falling = false
	position = _spawn_area.position


func _player_in_respawn_area() -> bool:
	return _spawn_area.get_overlapping_bodies().any(
		func(body: Node2D) -> bool: return body is Player
	)
