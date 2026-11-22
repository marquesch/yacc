@tool
class_name FallingPlatform
extends Platform

@export var gravity := 900.0
@export var delay := 0.5

var _velocity := 0.0
var _falling := false
var _triggered := false

@onready var trigger_area: Area2D = $TriggerArea
@onready var trigger_shape: RectangleShape2D = $TriggerArea/Shape


func _init() -> void:
	color = Color.RED


func _ready() -> void:
	super()
	trigger_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if not _falling:
		return
	_velocity += gravity * delta
	position.y += _velocity * delta


func _rebuild() -> void:
	if trigger_area == null:
		trigger_area = Area2D.new()
		trigger_area.name = "TriggerArea"
		add_child(trigger_area)

	if trigger_shape == null:
		trigger_shape = RectangleShape2D.new()
	trigger_shape.size = Vector2(size.x, 2)
	trigger_area.shape = trigger_shape
	trigger_area.position = Vector2(0, -size.y / 2.0 - 2)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not _triggered:
		_triggered = true
		get_tree().create_timer(delay).timeout.connect(func(): _falling = true)
