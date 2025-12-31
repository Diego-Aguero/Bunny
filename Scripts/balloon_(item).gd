extends Node2D

func _on_area_2d_area_entered(area):
	if area.is_in_group("HurtBoxPlayer"):
		$Sprite2D.visible = false
		$Area2D.set_deferred("monitoring", false)  # Desactiva el area para evitar multiples activaciones

func reactivate():
	$Sprite2D.visible = true
	$Area2D.set_deferred("monitoring", true)  # Reactiva el area para que pueda recogerse nuevamente
