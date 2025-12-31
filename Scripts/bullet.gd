extends Area2D

@export var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(_body: Node) -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()
