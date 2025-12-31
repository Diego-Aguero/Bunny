extends RigidBody2D

@export var max_speed: float = 200.0      
@export var acceleration: float = 300.0   

func _ready():
	linear_velocity = Vector2.ZERO

func _physics_process(delta):
	# Aumenta la velocidad (hacia arriba es negativa en Godot 2D)
	linear_velocity.y = linear_velocity.y - acceleration * delta
	
	# Restringe la velocidad para que no suba más rápido de max_speed
	linear_velocity.y = clamp(linear_velocity.y, -max_speed, max_speed)
