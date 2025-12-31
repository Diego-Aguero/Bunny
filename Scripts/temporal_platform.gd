extends StaticBody2D

@export var disable_delay: float = 1.5
@export var restart_delay: float = 2.0

var is_available: bool = true

func _ready():
	$Timer.wait_time = disable_delay
	$ReStartTimer.wait_time = restart_delay
	update_platform_state()

func _on_area_2d_area_entered(area):
	if area.is_in_group("HurtBoxPlayer") and is_available:
		$Area2D/CollisionShape2D.set_deferred("disabled", true)  # ← corregido
		$AnimatedSprite2D.play("Active")
		$Timer.start()

func disable_platform():
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 0.3)
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	is_available = false
	$AnimatedSprite2D.play("Idle")

func enable_platform():
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	$CollisionShape2D.disabled = false
	$Hitbox/CollisionShape2D.disabled = false
	is_available = true
	$AnimatedSprite2D.play("Idle")
	$Area2D/CollisionShape2D.disabled = false  # ← se reactiva cuando la plataforma vuelve

func update_platform_state():
	if is_available:
		enable_platform()
	else:
		disable_platform()

func _on_timer_timeout():
	disable_platform()
	$ReStartTimer.start()

func _on_re_start_timer_timeout():
	enable_platform()
