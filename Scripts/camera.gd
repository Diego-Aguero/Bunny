extends Camera2D

var shake_time := 0.0
var shake_intensity := 0.0
var rng = RandomNumberGenerator.new()

func _ready():
	make_current()

func _physics_process(delta):
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