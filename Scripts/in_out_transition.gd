extends CanvasLayer

@onready var color_rect: ColorRect = $Control/ColorRect
@onready var anim_player: AnimationPlayer = $Control/AnimationPlayer
var shader_material: ShaderMaterial

func _ready() -> void:
	shader_material = color_rect.material
	call_deferred("play_ease_in")

func play_ease_in() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	shader_material.set_shader_parameter("screen_width", viewport_size.x)
	shader_material.set_shader_parameter("screen_height", viewport_size.y)

	# Siempre usar el centro
	shader_material.set_shader_parameter("circle_position", Vector2(0.5, 0.5))

	anim_player.play("ease_in")

signal transition_finished

func play_ease_out() -> void:
	shader_material.set_shader_parameter("circle_position", Vector2(0.5, 0.5))
	anim_player.play("ease_out")
	await anim_player.animation_finished
	emit_signal("transition_finished")
