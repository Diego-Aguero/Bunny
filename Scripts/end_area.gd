extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.end_game_ctrl()
		
		# Reiniciar timer y esperar a que termine
		timer.start()
		await timer.timeout
		_go_to_end_screen()
		print($Timer.time_left)

func _go_to_end_screen():
	get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
