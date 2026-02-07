@tool
extends CharacterBody2D

enum State { FALLING, WAITING_AT_BOTTOM, RISING, WAITING_AT_TOP }
enum TriggerMode { TIMER, DETECTION }
enum CrusherDirection { UP, DOWN }

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

var current_state: int = State.WAITING_AT_TOP
var initial_position: Vector2
var bottom_position: Vector2
var delay_timer: float = 0.0
var player_in_area: bool = false

func _ready() -> void:
	# En el juego real, guarda la posición inicial.
	# En el editor, no quiero "congelar" la posición inicial.
	if not Engine.is_editor_hint():
		initial_position = global_position
		# Calcula el destino final basandose en la dirección
		match direction:
			CrusherDirection.DOWN:
				bottom_position = initial_position + Vector2(0, fall_distance)
			CrusherDirection.UP:
				bottom_position = initial_position - Vector2(0, fall_distance)
	
	# Fuerza una actualización visual al cargar para asegurar que todo cuadre
	_update_direction()
	_update_visuals()

func _update_visuals() -> void:
	# Verifica si los nodos existen antes de intentar configurarlos
	if has_node("LeftArea"):
		_configure_area($LeftArea, left_area_size, left_area_offset)
	if has_node("RightArea"):
		_configure_area($RightArea, right_area_size, right_area_offset)

func _update_direction() -> void:
	match direction:
		CrusherDirection.DOWN:
			rotation_degrees = 0
		CrusherDirection.UP:
			rotation_degrees = 180

# BUG FIX: RECURSO COMPARTIDO
func _configure_area(area: Area2D, size: Vector2, offset: Vector2) -> void:
	area.position = offset
	var col_node = area.get_node_or_null("CollisionShape2D")
	
	if col_node and col_node.shape is RectangleShape2D:
		# Si la forma no es única para esta escena, la duplica. Esto evita que al cambiar uno, cambien todos los demás Crushers.
		if not col_node.shape.resource_local_to_scene:
			col_node.shape = col_node.shape.duplicate()
			col_node.shape.resource_local_to_scene = true
		
		# Ahora puede cambiar el tamaño seguro de que es una copia única
		col_node.shape.size = size

func _physics_process(delta: float) -> void:
	# Si estamos en el editor, NO ejecutamos la lógica de movimiento
	if Engine.is_editor_hint():
		return
		
	match current_state:
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
			if trigger_mode == TriggerMode.TIMER:
				delay_timer -= delta
				if delay_timer <= 0:
					current_state = State.FALLING
			elif player_in_area:
				current_state = State.FALLING

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("HurtBoxPlayer"):
		player_in_area = true

func _on_area_exited(area: Node) -> void:
	if area.is_in_group("HurtBoxPlayer"):
		var still_in = false
		if has_node("LeftArea") and has_node("RightArea"):
			for a in $LeftArea.get_overlapping_areas() + $RightArea.get_overlapping_areas():
				if a.is_in_group("HurtBoxPlayer"):
					still_in = true
					break
		player_in_area = still_in