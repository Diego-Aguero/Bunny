extends StaticBody2D

enum FanDirection {
	Up,
	Down,
	Left,
	Right
}

@export var direction_option: FanDirection = FanDirection.Up
@export var push_force: float = 200.0

var push_direction: Vector2 = Vector2.UP
@onready var push_area: Area2D = $PushArea

func _ready():
	set_direction_option(direction_option)

func set_direction_option(option: FanDirection) -> void:
	direction_option = option
	match direction_option:
		FanDirection.Up:    push_direction = Vector2.UP
		FanDirection.Down:  push_direction = Vector2.DOWN
		FanDirection.Left:  push_direction = Vector2.LEFT
		FanDirection.Right: push_direction = Vector2.RIGHT
	rotation = push_direction.angle()

func _physics_process(delta):
	for body in push_area.get_overlapping_bodies():
		if body is CharacterBody2D:
			var force = push_direction.normalized() * push_force * delta

			if direction_option == FanDirection.Up or direction_option == FanDirection.Down:
				if "current_gravity_direction" in body:
					force.y *= body.current_gravity_direction

			if "fan_push" in body:
				body.fan_push += force

			if direction_option == FanDirection.Up or direction_option == FanDirection.Down:
				if body.has_method("set_fan_zone_state"):
					body.set_fan_zone_state(true)

func _on_push_area_body_exited(body):
	if body is CharacterBody2D:
		if direction_option == FanDirection.Up or direction_option == FanDirection.Down:
			if body.has_method("set_fan_zone_state"):
				body.set_fan_zone_state(false)

			# Anular fan_push.y solo si es ventilador hacia abajo
			if direction_option == FanDirection.Down:
				if "fan_push" in body:
					body.fan_push.y = 0
