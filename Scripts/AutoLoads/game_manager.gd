extends Node

var time_in_game: float
var is_dead: bool = false
var is_on_dead_transition: bool = false
var is_level_complete: bool  = false
var death_count: int = 0
var elapsed_time: float = 0.0

func _process(delta):
	elapsed_time += delta

func add_death():
	death_count += 1

func reset_stats():
	death_count = 0
	elapsed_time = 0.0

var last_checkpoint_position: Vector2 = Vector2.ZERO

func reset_scene() -> void:
	is_dead = false 
	get_tree().reload_current_scene()
	print("Escena reseteada. Checkpoint actual: ", last_checkpoint_position)

func clear_checkpoint():
	last_checkpoint_position = Vector2.ZERO
	is_level_complete = false
