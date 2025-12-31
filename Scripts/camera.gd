extends Camera2D

var player: CharacterBody2D
var shake_time := 0.0
var shake_intensity := 0.0
var rng = RandomNumberGenerator.new()

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if player:
		global_position = player.global_position
	make_current()

func _physics_process(delta):
	if !player or GameManager.is_dead:
		player = get_tree().get_first_node_in_group("Player")
		return
	
	if !GameManager.is_dead:
		var target_pos = player.global_position
		
		global_position.x = round(target_pos.x)
		global_position.y = round(target_pos.y)

	if shake_time > 0:
		shake_time -= delta
		var shake_offset = Vector2(
			rng.randf_range(-shake_intensity, shake_intensity),
			rng.randf_range(-shake_intensity, shake_intensity)
		)
		offset = shake_offset.round()
	else:
		offset = Vector2.ZERO

func shake(duration: float, intensity: float):
	shake_time = duration
	shake_intensity = intensity
