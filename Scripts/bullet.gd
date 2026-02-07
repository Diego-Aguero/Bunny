extends Area2D

@export var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_body_entered(body: Node) -> void:

	if body.has_method("death_ctrl") or body.is_in_group("Player"):
		return
	# Si choca con paredes, suelo, techos, etc., se destruye.
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "GrabArea" or area.is_in_group("Grab"):
		return
	queue_free() 