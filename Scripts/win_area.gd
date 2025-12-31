extends Area2D

@export var siguiente_nivel : String = "0"

func _on_area_entered(area):
	if area.is_in_group("HurtBoxPlayer"):
		GameManager.clear_checkpoint() # Borra el checkpoint antes de cargar
		var path = "res://Scenes/Levels/level_" + siguiente_nivel + ".tscn"
		get_tree().call_deferred("change_scene_to_file", path)
		print("Entrando a nivel " + path)
