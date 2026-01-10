@tool
extends CharacterBody2D

# --- ENUMS ---
enum State { FALLING, WAITING_AT_BOTTOM, RISING, WAITING_AT_TOP, ANTICIPATION }
enum TriggerMode { TIMER, DETECTION }
enum CrusherDirection { UP, DOWN }

# --- EXPORTS ---
@export var trigger_mode: TriggerMode = TriggerMode.DETECTION
@export var direction: CrusherDirection = CrusherDirection.DOWN:
	set(value):
		direction = value
		if Engine.is_editor_hint(): _update_direction()

@export var fall_speed: float = 200.0
@export var rise_speed: float = 15.0
@export var fall_distance: float = 32.0

@export var delay_after_fall: float = 0.5
@export var delay_after_rise: float = 0.5

@export_group("Configuración de Shake")
@export var anticipation_time: float = 0.5  # Tiempo que dura la vibración
@export var shake_intensity: float = 5.0    # Grados de rotación
@export var shake_speed: float = 0.05       # Velocidad de cada sacudida (Menor = más rápido)

@export_group("Configuración de Areas")
@export var left_area_size: Vector2 = Vector2(32, 64):
	set(value):
		left_area_size = value
		if Engine.is_editor_hint(): _update_visuals()
@export var right_area_size: Vector2 = Vector2(32, 64):
	set(value):
		right_area_size = value
		if Engine.is_editor_hint(): _update_visuals()
@export var left_area_offset: Vector2 = Vector2(-32, 0):
	set(value):
		left_area_offset = value
		if Engine.is_editor_hint(): _update_visuals()
@export var right_area_offset: Vector2 = Vector2(32, 0):
	set(value):
		right_area_offset = value
		if Engine.is_editor_hint(): _update_visuals()

# --- VARIABLES INTERNAS ---
var current_state: int = State.WAITING_AT_TOP
var initial_position: Vector2
var bottom_position: Vector2
var delay_timer: float = 0.0
var player_in_area: bool = false
var shake_tween: Tween # Variable para guardar el Tween

# Referencia al contenedor visual
@onready var visual_node: Node2D = $Visuals 

func _ready() -> void:
	if not Engine.is_editor_hint():
		initial_position = global_position
		match direction:
			CrusherDirection.DOWN:
				bottom_position = initial_position + Vector2(0, fall_distance)
			CrusherDirection.UP:
				bottom_position = initial_position - Vector2(0, fall_distance)
	
	_update_direction()
	_update_visuals()

# --- FUNCIONES DE TWEEN (NUEVO) ---
func start_shake() -> void:
	if not visual_node: return
	
	# Si ya existe un tween, lo matamos para empezar uno nuevo limpio
	if shake_tween: shake_tween.kill()
	
	shake_tween = create_tween().set_loops() # set_loops() hace que sea infinito
	
	# Interpolamos de 0 a +Intensidad
	shake_tween.tween_property(visual_node, "rotation_degrees", shake_intensity, shake_speed).set_trans(Tween.TRANS_SINE)
	# Interpolamos de +Intensidad a -Intensidad
	shake_tween.tween_property(visual_node, "rotation_degrees", -shake_intensity, shake_speed * 2).set_trans(Tween.TRANS_SINE)
	# Interpolamos de -Intensidad a 0 (Para cerrar el ciclo si parara, aunque aquí loopea)
	shake_tween.tween_property(visual_node, "rotation_degrees", shake_intensity, shake_speed * 2).set_trans(Tween.TRANS_SINE)

func stop_shake() -> void:
	# Matamos el tween y reseteamos la rotación a 0
	if shake_tween: shake_tween.kill()
	if visual_node:
		# Usamos un tween rápido para volver a 0 suavemente en lugar de golpe
		var reset_tween = create_tween()
		reset_tween.tween_property(visual_node, "rotation_degrees", 0.0, 0.1)

# ----------------------------------

func _update_visuals() -> void:
	if has_node("LeftArea"): _configure_area($LeftArea, left_area_size, left_area_offset)
	if has_node("RightArea"): _configure_area($RightArea, right_area_size, right_area_offset)

func _update_direction() -> void:
	match direction:
		CrusherDirection.DOWN: rotation_degrees = 0
		CrusherDirection.UP: rotation_degrees = 180

func _configure_area(area: Area2D, size: Vector2, offset: Vector2) -> void:
	area.position = offset
	var col_node = area.get_node_or_null("CollisionShape2D")
	if col_node and col_node.shape is RectangleShape2D:
		if not col_node.shape.resource_local_to_scene:
			col_node.shape = col_node.shape.duplicate()
			col_node.shape.resource_local_to_scene = true
		col_node.shape.size = size

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
        
	match current_state:
		State.ANTICIPATION:
			delay_timer -= delta
			# YA NO HACEMOS NADA AQUÍ, EL TWEEN SE ENCARGA DEL MOVIMIENTO
			
			if delay_timer <= 0:
				stop_shake() # <--- IMPORTANTE: Detener el shake al salir
				current_state = State.FALLING

		State.FALLING:
			global_position.y = move_toward(global_position.y, bottom_position.y, fall_speed * delta)
			if global_position.y == bottom_position.y:
				current_state = State.WAITING_AT_BOTTOM
				delay_timer = delay_after_fall
				
		State.WAITING_AT_BOTTOM:
			delay_timer -= delta
			if delay_timer <= 0:
				current_state = State.RISING
				
		State.RISING:
			global_position.y = move_toward(global_position.y, initial_position.y, rise_speed * delta)
			if global_position.y == initial_position.y:
				current_state = State.WAITING_AT_TOP
				delay_timer = delay_after_rise if trigger_mode == TriggerMode.TIMER else 0.0
				
		State.WAITING_AT_TOP:
			var should_fall = false
			if trigger_mode == TriggerMode.TIMER:
				delay_timer -= delta
				if delay_timer <= 0: should_fall = true
			elif player_in_area:
				should_fall = true
			
			if should_fall:
				start_shake() # <--- IMPORTANTE: Iniciar el shake al entrar
				current_state = State.ANTICIPATION
				delay_timer = anticipation_time

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("HurtBoxPlayer"): player_in_area = true

func _on_area_exited(area: Node) -> void:
	if area.is_in_group("HurtBoxPlayer"):
		var still_in = false
		if has_node("LeftArea") and has_node("RightArea"):
			for a in $LeftArea.get_overlapping_areas() + $RightArea.get_overlapping_areas():
				if a.is_in_group("HurtBoxPlayer"):
					still_in = true
					break
		player_in_area = still_in