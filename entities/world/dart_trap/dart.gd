class_name Dart
extends Area2D

@export var speed: int = 100
@export var lifetime: int = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime, false).timeout.connect(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.kill()
	queue_free()
