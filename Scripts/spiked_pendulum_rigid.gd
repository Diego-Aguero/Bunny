extends RigidBody2D

# Variables internas con valores por defecto.
var impulse_x: int = 300
var impulse_y: int = 0
var direction: int = 1  # 1 = derecha, -1 = izquierda
var threshold: float = 0.1  # Límite para invertir dirección
@export var gravity_direction: int = 1  # 1 = gravedad hacia abajo, -1 = gravedad hacia arriba

# Función para recibir y asignar los parámetros desde el nodo padre.
func set_impulse_parameters(new_impulse_x: int, new_impulse_y: int, new_direction: int, new_threshold: float) -> void:
	impulse_x = new_impulse_x
	impulse_y = new_impulse_y
	direction = new_direction
	threshold = new_threshold

func _ready():
	# Aplica el primer impulso adaptado a la dirección de la gravedad.
	apply_central_impulse(Vector2(impulse_x * direction * gravity_direction, impulse_y))

func _physics_process(_delta):
	# Si la velocidad cambia de dirección, aplicar un nuevo impulso adaptado a la gravedad.
	if linear_velocity.x < -threshold and direction == 1:
		direction = -1
		apply_central_impulse(Vector2(impulse_x * direction * gravity_direction, impulse_y))
	elif linear_velocity.x > threshold and direction == -1:
		direction = 1
		apply_central_impulse(Vector2(impulse_x * direction * gravity_direction, impulse_y))
