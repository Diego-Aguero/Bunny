extends Node2D

@export var raise_amount: float = 15
@export var raise_speed: float = 100
@export var CicleTime: float = 2.0
@export var CurrentState: bool = true  # true = arriba, false = abajo

@onready var start_position: Vector2 = position
@onready var target_position: Vector2 = position - Vector2(0, raise_amount)
@onready var collision_area: Area2D = $Area2D
@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = CicleTime
	timer.start()
	# Inicializar posición correcta según el estado
	if CurrentState:
		position.y = target_position.y
		collision_area.monitoring = true
	else:
		position.y = start_position.y
		collision_area.monitoring = false

func _physics_process(delta):
	if CurrentState:
		# Subir si no está ya en target
		if position.y > target_position.y:
			position.y = move_toward(position.y, target_position.y, raise_speed * delta)
	else:
		# Bajar si no está ya abajo
		if position.y < start_position.y:
			position.y = move_toward(position.y, start_position.y, raise_speed * delta)

func _on_timer_timeout():
	if CurrentState:
		# bajar
		CurrentState = false
		collision_area.monitoring = false
	else:
		# subir
		CurrentState = true
		collision_area.monitoring = true
