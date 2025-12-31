extends Area2D

func _ready():
	if GameManager.last_checkpoint_position == Vector2.ZERO:
		GameManager.last_checkpoint_position = global_position

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.last_checkpoint_position = global_position
