extends Area2D

@export var zone_camera: PhantomCamera2D 

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if zone_camera.get_follow_target() == null:
			zone_camera.set_follow_target(body)
		zone_camera.set_priority(20)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		zone_camera.set_priority(0)
