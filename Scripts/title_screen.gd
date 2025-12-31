extends Control

var level_scene_path = "res://Scenes/level_selector.tscn"
var starting_delay: float = 0.5
func _process(_delta):
	if Input.is_anything_pressed():
		$AnimationPlayer.play("Starting")
		await get_tree().create_timer(starting_delay).timeout
		get_tree().change_scene_to_file(level_scene_path)
	 #else:
		#push_error("No se definió la ruta de la escena")
