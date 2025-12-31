extends Area2D

# Enum para las direcciones de gravedad (solo Down y Up)
enum GravityType { Down, Up }

@export var zone_gravity_direction: GravityType = GravityType.Down
@export var transition_time: float = 0.5

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# Calcula el target_direction según la zona: 1.0 para Down, -1.0 para Up.
		var target_direction: float = 1.0 if zone_gravity_direction == GravityType.Down else -1.0
		# Si el jugador ya tiene esa dirección, no se reinicia.
		if is_equal_approx(body.current_gravity_direction, target_direction):
			return
		body.active_gravity_zone = self
		body.change_gravity(int(zone_gravity_direction), transition_time)

func _on_body_exited(body):
	if body.is_in_group("Player") and body.active_gravity_zone == self:
		body.active_gravity_zone = null
