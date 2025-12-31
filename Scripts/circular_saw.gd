extends CharacterBody2D

# Usa el mismo codigo que la plataforma móvil pero con un cambio al final: si la posicion inicial es igual a 0,0
# entonces la posicion final es igual a la  posicion inicial, asi para no tener que estar todo el rato cambiando la posicion 
# final de las sierras que no quiero que se muevan. Se podria hacer mejor para la version final, en lugar de que
# sea en Vector2(0,0) y dar lugar a posibles fallos puedo hacer un booleano y que si sea true la posicion es igual
# a start position, y asi lo uso como un botón exportado en el inspector sin que afecte a lo que pase en el juego.

# Solo define el destino final del recorrido
@export var end_pos: Vector2
@export var movement_duration: float = 5.0

var start_pos: Vector2  # obtiene la posicion inicial automaticamente (de donde lo ponga)
var current_t: float = 0.0 #t se refiero al tiempo, pero al tiempo normalizado, el que pasa entre el inicio 0% y el final 100%. se usa por convencion en animaciones/interpolaciones
var direction: int = 1

func _ready():
	start_pos = position  # la del escenario tambien

func _physics_process(delta):
	current_t += delta * direction / movement_duration
	current_t = clampf(current_t, 0.0, 1.0)
	
	var eased_t = ease_in_out(current_t)
	var target_position = start_pos.lerp(end_pos, eased_t)
	
	velocity = (target_position - position) / delta
	move_and_slide()
	
	if current_t >= 1.0 or current_t <= 0.0:
		direction *= -1
	
	if end_pos == Vector2(0,0): # El cambio del que hable al principio.
		end_pos = start_pos

func ease_in_out(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)
