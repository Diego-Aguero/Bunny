extends Node

var _touch_input : int = 0     # -1 = izquierda, 0 = sin toque, 1 = derecha

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_input = -1 if event.position.x < get_viewport().get_visible_rect().size.x * 0.5 else 1
		else:
			_touch_input = 0
	elif event is InputEventScreenDrag:
		# mientras arrastra, sigue actualizando la orientación
		_touch_input = -1 if event.position.x < get_viewport().get_visible_rect().size.x * 0.5 else 1

func get_axis() -> Vector2:
	var kb := int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var x := kb + _touch_input
	# Clamp "x" a [-1, 1]
	x = clamp(x, -1, 1)
	return Vector2(x, 0)
