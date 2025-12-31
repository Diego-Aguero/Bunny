extends CharacterBody2D

# Solo define el destino final del recorrido
@export var end_pos: Vector2
@export var movement_duration: float = 5.0

var start_pos: Vector2  # obtiene la posicion inicial automaticamente (de donde lo ponga)
var current_t: float = 0.0 #t se refiero al tiempo, pero al tiempo normalizado, el que pasa entre el inicio 0% y el final 100%. se usa por convencion en animaciones/interpolaciones
var direction: int = 1

func _ready():
	start_pos = position  # la del escenario tambien.

func _physics_process(delta):
	current_t += delta * direction / movement_duration
	current_t = clampf(current_t, 0.0, 1.0)
	
	var eased_t = ease_in_out(current_t)
	var target_position = start_pos.lerp(end_pos, eased_t)
	
	velocity = (target_position - position) / delta
	move_and_slide()
	
	if current_t >= 1.0 or current_t <= 0.0:
		direction *= -1

func ease_in_out(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)
