extends StaticBody2D

enum FanDirection {
	Up,
	Down,
	Left,
	Right
}

@export var direction_option: FanDirection = FanDirection.Up
var push_direction: Vector2 = Vector2.UP

# Variables para configurar el disparo
@export var bullet_scene: PackedScene         # Arrastra tu bullet.tscn aquí
@export var bullet_speed: float = 300.0         # Velocidad de la bala
@export var charging_time: float = 1.0          # Tiempo de la animación de carga
@export var shoot_time: float = 0.15             # Tiempo de la animación de disparo
@export var cooldown_time: float = 1.0          # Tiempo de la animación de cooldown

var state: String = "Charging"
@onready var timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	set_direction_option(direction_option)
	# Configuramos el Timer en modo one_shot
	timer.one_shot = true
	# Conecta la señal "timeout" si aún no está conectada
	if not timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		timer.timeout.connect(Callable(self, "_on_timer_timeout"))
	# Iniciamos con la animación de carga
	_play_charging()

func set_direction_option(option: FanDirection) -> void:
	direction_option = option
	match direction_option:
		FanDirection.Up:    push_direction = Vector2.UP
		FanDirection.Down:  push_direction = Vector2.DOWN
		FanDirection.Left:  push_direction = Vector2.LEFT
		FanDirection.Right: push_direction = Vector2.RIGHT
	rotation = push_direction.angle()

func _play_charging() -> void:
	state = "Charging"
	animated_sprite.play("Charging")
	timer.wait_time = charging_time
	timer.start()

func _play_shoot() -> void:
	state = "Shoot"
	animated_sprite.play("Shoot")
	_shoot_bullet() # Instancia la bala en el momento de disparar
	timer.wait_time = shoot_time
	timer.start()

func _play_cooldown() -> void:
	state = "Cooldown"
	animated_sprite.play("Cooldown")
	timer.wait_time = cooldown_time
	timer.start()

func _on_timer_timeout() -> void:
	match state:
		"Charging":
			_play_shoot()
		"Shoot":
			_play_cooldown()
		"Cooldown":
			_play_charging()

func _shoot_bullet() -> void:
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		# Ubica la bala en la posición del cañón, con un pequeño offset en la dirección del disparo
		bullet.position = global_position + push_direction * 10
		# Asigna la velocidad: primero verifica si existe el método "set_velocity"
		if bullet.has_method("set_velocity"):
			bullet.set_velocity(push_direction * bullet_speed)
		else:
			# Comprueba si la propiedad "velocity" existe en el bullet
			var property_exists: bool = false
			for prop in bullet.get_property_list():
				if prop.has("name") and prop["name"] == "velocity":
					property_exists = true
					break
			if property_exists:
				bullet.velocity = push_direction * bullet_speed
		# Añade la bala a la escena actual
		get_tree().current_scene.add_child(bullet)
