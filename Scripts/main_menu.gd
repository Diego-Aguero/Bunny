# MainMenu.gd
extends Control

@export_range(0.0, 1000.0) var radius: float = 200.0
@export_range(0.1, 2.0) var min_scale: float = 0.7
@export_range(0.1, 2.0) var max_scale: float = 1.2
@export_range(0.1, 5.0) var rotation_time: float = 0.4
@export var initial_selected_index: int = 0
@export var start_angle_offset: float = -PI/2.0

signal item_selected(index: int)

var items: Array[TextureButton] = []
var angle_step: float
var tween: Tween
var _base_angle: float = 0.0

var base_angle:
	get: return _base_angle
	set(value):
		_base_angle = value
		update_items()

func _ready() -> void:
	# Configurar botones
	for child in get_children():
		if child is TextureButton:
			child.focus_mode = Control.FOCUS_ALL
			child.focus_mode = Control.FOCUS_CLICK
			items.append(child)
			child.pressed.connect(_on_item_pressed.bind(child))
	
	if items.is_empty():
		push_error("MainMenu: No se encontraron botones")
		return
	
	angle_step = TAU / items.size()
	initial_selected_index = posmod(initial_selected_index, items.size())
	base_angle = -initial_selected_index * angle_step
	
	set_focus_mode(Control.FOCUS_ALL)
	grab_focus()
	update_items()

func _focus_front_item() -> void:
	var front_index = _get_front_index()
	if front_index >= 0:
		items[front_index].grab_focus()

func update_items() -> void:
	var center = size * 0.5
	for i in items.size():
		var btn = items[i]
		var display_angle = base_angle + i * angle_step + start_angle_offset
		
		var offset = Vector2(cos(display_angle), sin(display_angle)) * radius
		btn.position = center + offset - btn.size * btn.scale * 0.5
		
		var t = (-sin(display_angle) + 1.0) * 0.5
		btn.scale = Vector2.ONE * lerp(min_scale, max_scale, t)
		
		btn.visible = sin(display_angle) < 0
		btn.set_meta("display_angle", display_angle)
		btn.z_index = int(btn.scale.x * 100)

func rotate_menu(direction: int) -> void:
	if tween && tween.is_running():
		return  # Bloquea el movimiento si ya está rotando
	
	var target = base_angle - angle_step * direction
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "base_angle", target, rotation_time)
	tween.finished.connect(_focus_front_item)
	
	update_items()
	_focus_front_item()

func _get_front_index() -> int:
	var front_index = -1
	var closest_diff = INF
	
	for i in items.size():
		var btn = items[i]
		if btn.visible:
			var display_angle = btn.get_meta("display_angle")
			var angle_diff = abs(fmod(display_angle - start_angle_offset, TAU))
			angle_diff = min(angle_diff, TAU - angle_diff)
			
			if angle_diff < closest_diff:
				closest_diff = angle_diff
				front_index = i
				
	return front_index

func _on_item_pressed(btn: TextureButton) -> void:
	var index = items.find(btn)
	if index != -1:
		item_selected.emit(index)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		rotate_menu(1)
		accept_event()
	elif event.is_action_pressed("ui_right"):
		rotate_menu(-1)
		accept_event()
	elif event.is_action_pressed("ui_accept") && _get_front_index() != -1:
		items[_get_front_index()].emit_signal("pressed")
		accept_event()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		if !has_focus():
			grab_focus()
