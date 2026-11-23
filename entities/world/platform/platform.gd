@tool
class_name Platform
extends AnimatableBody2D
## A solid rectangle. Set `size` in the inspector; the node's origin is its top-left corner.
##
## The visual and the collision shape are created in code from `size`, so every instance
## has its own shape and level scenes only need to store a position and a size. `@tool`
## makes this run in the editor too, so platforms show up while you design a level.

@export var size := Vector2(32, 8):
	set(value):
		size = value
		if is_node_ready():
			_rebuild()

@export var color := Color(0.55, 0.6, 0.75):
	set(value):
		color = value
		if is_node_ready():
			_rebuild()

@onready var rect: ColorRect = get_node_or_null("Rect")
@onready var shape_node: CollisionShape2D = get_node_or_null("Shape")


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if rect == null:
		rect = ColorRect.new()
		rect.name = "Rect"
		add_child(rect)
	rect.position = -size / 2.0
	rect.size = size
	rect.color = color

	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "Shape"
		add_child(shape_node)
	shape_node.position *= 0
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
