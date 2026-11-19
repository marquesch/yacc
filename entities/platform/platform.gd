@tool
class_name Platform
extends StaticBody2D
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


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	var rect: ColorRect = get_node_or_null("Rect")
	if rect == null:
		rect = ColorRect.new()
		rect.name = "Rect"
		add_child(rect)
	rect.size = size
	rect.color = color

	var shape_node: CollisionShape2D = get_node_or_null("Shape")
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "Shape"
		add_child(shape_node)
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
	shape_node.position = size / 2.0
