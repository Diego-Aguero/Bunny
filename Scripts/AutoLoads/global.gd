extends Node

# Pila para guardar el historial de inputs.
# -1 = Izquierda, 1 = Derecha.
var _input_stack: Array[int] = []

func _input(event):

	# LÓGICA TÁCTIL

	# Detecta en qué mitad de la pantalla tocó el dedo.

	if event is InputEventScreenTouch:
		# Si la X es menor a la mitad del ancho, es Izquierda (-1), sino Derecha (1)
		var side = -1 if event.position.x < get_viewport().get_visible_rect().size.x * 0.5 else 1
		
		if event.pressed:
			_push_input(side)
		else:
			_pop_input(side)
	
	# LÓGICA DE ACCIONES (Teclado o Gamepad)

	# elif' para no procesar dos veces si un evento cumple ambas condiciones
	elif event.is_action("ui_left") or event.is_action("ui_right"):
		
		# Ignora cuando dejas la tecla apretada
		if event.is_echo():
			return

		# IZQUIERDA
		if event.is_action_pressed("ui_left"):
			_push_input(-1)
		elif event.is_action_released("ui_left"):
			_pop_input(-1)
			
		# DERECHA
		if event.is_action_pressed("ui_right"):
			_push_input(1)
		elif event.is_action_released("ui_right"):
			_pop_input(1)

# FUNCIONES HELPER 

# Añade la dirección a la pila si no existe ya
func _push_input(val: int) -> void:
	if not val in _input_stack:
		_input_stack.append(val)

# Elimina la dirección de la pila
func _pop_input(val: int) -> void:
	_input_stack.erase(val)

# FUNCIÓN PÚBLICA (Para usar en Player)

func get_axis() -> Vector2:
	var final_dir: int = 0
	
	# .back() devuelve el ÚLTIMO elemento añadido. el input más reciente siempre tiene prioridad.
	if not _input_stack.is_empty():
		final_dir = _input_stack.back()
	
	return Vector2(final_dir, 0)
