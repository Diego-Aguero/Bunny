extends AnimatableBody2D

enum GravityDirection { Down, Up }
@export var gravity_direction: GravityDirection = GravityDirection.Down
@export var direction: Vector2 = Vector2.RIGHT
@export var conveyor_speed: float = 200.0
@export var launch_force: float = 500.0

@onready var sticky_area: Area2D = $Sticky

func _ready():
	sticky_area.body_entered.connect(_on_body_entered)
	sticky_area.body_exited.connect(_on_body_exited)
	# Ajusta la rotación visual según gravity_direction
	match gravity_direction:
		GravityDirection.Down:
			rotation_degrees = 0
		GravityDirection.Up:
			rotation_degrees = 180

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.current_conveyor = self
		# Al entrar, detenemos el movimiento vertical
		body.velocity.y = 0

func _on_body_exited(body):
	# El impulso de salida se maneja en el player (handle_conveyor_exit), donde se podrá leer gravity_direction.
	if body.is_in_group("Player") and body.current_conveyor == self:
		body.handle_conveyor_exit(sticky_area)
