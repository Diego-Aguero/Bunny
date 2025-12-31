extends Node2D

enum State { WAITING, RAISING, LOWERING }

@export var raise_amount: float = 15
@export var raise_speed: float = 100
@export var raise_delay: float = 0.2    # Delay antes de subir tras la detección
@export var stay_duration: float = 1.5
@export var cooldown_duration: float = 2.0

@onready var start_position: Vector2 = position
@onready var stand_timer: Timer = $StandTimer
@onready var collision_area: Area2D = $Area2D
@onready var raycast: RayCast2D = $RayCast2D

var current_state: State = State.WAITING
var target_position: Vector2
var triggered: bool = false

func _ready():
	target_position = position - Vector2(0, raise_amount)
	collision_area.monitoring = false

func _physics_process(delta):
	if current_state == State.WAITING and not triggered and raycast.is_colliding():
		triggered = true
		await get_tree().create_timer(raise_delay).timeout
		start_movement()

	match current_state:
		State.RAISING:
			position.y = move_toward(position.y, target_position.y, raise_speed * delta)
			if position.y <= target_position.y:
				finish_raising()
		
		State.LOWERING:
			position.y = move_toward(position.y, start_position.y, raise_speed * delta)
			if position.y >= start_position.y:
				finish_cycle()

func start_movement():
	current_state = State.RAISING
	collision_area.monitoring = true

func finish_raising():
	current_state = State.WAITING
	stand_timer.start(stay_duration)

func start_lowering():
	current_state = State.LOWERING
	collision_area.monitoring = false

func finish_cycle():
	current_state = State.WAITING
	triggered = false
	await get_tree().create_timer(cooldown_duration).timeout

func _on_stand_timer_timeout():
	start_lowering()
