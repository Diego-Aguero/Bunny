extends Node2D

enum GravityDirection { Down, Up }
@export var gravity_direction: GravityDirection = GravityDirection.Down
@export var launch_force: float = 500.0
@export var speed: float = 150.0
@export var direction: Vector2 = Vector2.RIGHT  # Dirección horizontal predominante

func _ready():
	# Ajusta la rotación visual de la zipline según gravity_direction
	match gravity_direction:
		GravityDirection.Down:
			rotation_degrees = 0
		GravityDirection.Up:
			rotation_degrees = 180

func _on_grab_area_area_entered(area):
	if area.is_in_group("Player"):
		var player = area
		player.current_zipline = self
		player.current_conveyor = null
		player.velocity = Vector2.ZERO
		# Alinea verticalmente al zipline
		player.global_position.y = global_position.y

func _on_grab_area_area_exited(area):
	if area.is_in_group("Player"):
		var player = area
		if player.current_zipline == self:
			var exit_side = sign(player.global_position.x - global_position.x)
			if exit_side == sign(direction.x):
				var impulse = direction
				# Si hay componente vertical y la zipline está en modo Up, invertimos la Y
				if impulse.y != 0 and gravity_direction == GravityDirection.Up:
					impulse.y = -impulse.y
				player.velocity = impulse * launch_force
			player.current_zipline = null
