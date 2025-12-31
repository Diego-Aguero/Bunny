extends StaticBody2D
@export var CurrentState: bool = true
@export var CicleTime: float = 1.0

func _ready():
	$Timer.wait_time = CicleTime

func _on_timer_timeout():
	if CurrentState == true:
		off()
	else: 
		on()

func on():
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 0.3)
	$Area2D/CollisionShape2D.disabled = true
	CurrentState = true

func off():
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	$Area2D/CollisionShape2D.disabled = false
	CurrentState = false
