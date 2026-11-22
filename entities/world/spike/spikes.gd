@tool
class_name Spikes
extends Area2D

enum Facing { UP, RIGHT, DOWN, LEFT }

const TILE := 16
const HITBOX_HEIGHT := 8.0
const HITBOX_INSET := 1.0

@export_range(1, 64) var count := 4:
	set(value):
		count = value
		if is_node_ready():
			_rebuild()

@export var facing := Facing.UP:
	set(value):
		facing = value
		if is_node_ready():
			_rebuild()

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	_rebuild()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _rebuild() -> void:
	rotation = facing * PI / 2.0
	var width := TILE * count

	sprite.centered = false
	sprite.position = Vector2(0, -TILE)
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, width, TILE)

	var shape_node: CollisionShape2D = get_node_or_null("Shape")
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "Shape"
		add_child(shape_node)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(width - HITBOX_INSET * 2.0, HITBOX_HEIGHT)
	shape_node.shape = shape
	shape_node.position = Vector2(width / 2.0, -HITBOX_HEIGHT / 2.0)


func _on_body_entered(body: Node2D):
	if body is Player:
		body.kill()
