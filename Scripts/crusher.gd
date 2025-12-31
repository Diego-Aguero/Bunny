extends CharacterBody2D

enum State { FALLING, WAITING_AT_BOTTOM, RISING, WAITING_AT_TOP }
enum TriggerMode { TIMER, DETECTION }
enum CrusherDirection { UP, DOWN }  # Nuevo enum para dirección

@export var trigger_mode: TriggerMode = TriggerMode.DETECTION
@export var direction: CrusherDirection = CrusherDirection.DOWN  # Dirección predeterminada: abajo

# Velocidades (píxeles por segundo)
@export var fall_speed: float = 200.0
@export var rise_speed: float = 15.0

# Distancia de caída/ascenso
@export var fall_distance: float = 32.0

# Tiempos de espera (segundos)
@export var delay_after_fall: float = 0.5
@export var delay_after_rise: float = 0.5

# Configuración de áreas
@export var left_area_size: Vector2 = Vector2(100, 100)
@export var right_area_size: Vector2 = Vector2(100, 100)
@export var left_area_offset: Vector2 = Vector2(-5, 0)
@export var right_area_offset: Vector2 = Vector2(5, 0)

var current_state: int = State.WAITING_AT_TOP
var initial_position: Vector2
var bottom_position: Vector2
var delay_timer: float = 0.0
var player_in_area: bool = false

func _ready() -> void:
	initial_position = global_position
	_update_direction()  # Configurar dirección inicial
	_configure_area($LeftArea, left_area_size, left_area_offset)
	_configure_area($RightArea, right_area_size, right_area_offset)

func _update_direction() -> void:
	match direction:
		CrusherDirection.DOWN:
			bottom_position = initial_position + Vector2(0, fall_distance)
			rotation_degrees = 0
		CrusherDirection.UP:
			bottom_position = initial_position - Vector2(0, fall_distance)
			rotation_degrees = 180

func _configure_area(area: Area2D, size: Vector2, offset: Vector2) -> void:
	area.position = offset
	var shape = area.get_node_or_null("CollisionShape2D")
	if shape and shape.shape is RectangleShape2D:
		shape.shape.size = size

func _physics_process(delta: float) -> void:
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
		for a in $LeftArea.get_overlapping_areas() + $RightArea.get_overlapping_areas():
			if a.is_in_group("HurtBoxPlayer"):
				still_in = true
				break
		player_in_area = still_in
