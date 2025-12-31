extends Node2D

@export var spring_strength: float = 450.0
@export var bounce_duration: float = 0.3  # Duración de la animación de rebote en segundos

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var bouncing: bool = false

func _ready() -> void:
	animated_sprite.play("Idle")

func _on_area_2d_body_entered(body: Node) -> void:
	if bouncing:
		return

	if body.is_in_group("Player"):
		bouncing = true
		# Aplica la fuerza contraria a la gravedad actual:
		body.velocity.y = -spring_strength * body.current_gravity_direction
		if body.has_method("set_trampoline_boost"):
			body.set_trampoline_boost(true)
		animated_sprite.play("Bouncing")
		await get_tree().create_timer(bounce_duration).timeout
		animated_sprite.play("Idle")
		bouncing = false
