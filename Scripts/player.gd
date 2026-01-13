extends CharacterBody2D

@export var gravity: int = 850
@export var jump_force: int = 280
var trampoline_boost: bool = false

@export var max_speed: float = 180.0
@export var acceleration: float = 10.0
@export var deceleration: float = 20.0

@export var fan_max_speed_x: float = 600.0
@export var fan_max_speed_y: float = 800.0
@export var fan_friction: float = 0.9
@export var has_balloon: bool = false
@export var max_fall_speed_with_balloon: float = 70.0
@export var player_direction: Vector2
@onready var pcam = $PhantomCamera2D

var is_in_vertical_fan: bool = false
var balloon_item_ref: Node2D = null

var current_conveyor: AnimatableBody2D = null
var current_zipline: AnimatableBody2D = null
var input_velocity_x: float = 0.0
var fan_push: Vector2 = Vector2.ZERO

var current_gravity_direction: float = 1.0
var current_gravity_type: int = 0
var pending_gravity_type: int = 0
var is_changing_gravity: bool = false
var active_gravity_zone: Node = null
var is_dead: bool = false
var can_move : bool

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var current_anim: String = ""

func _ready() -> void:
	if not GameManager.is_level_complete and GameManager.last_checkpoint_position != Vector2.ZERO:
		global_position = GameManager.last_checkpoint_position
	
	$CollisionPolygon2D.set_deferred("disabled", false)
	$HurtBoxPlayer/CollisionShape2D.set_deferred("disabled", false)
	$GrabArea/CollisionShape2D.set_deferred("disabled", false)
	$StartingTime.start()
	can_move = false
	if player_direction.x != 0:
		$AnimatedSprite2D.flip_h = player_direction.x < 0

func _physics_process(delta):
	if not can_move or is_dead:
		return
	
	apply_gravity(delta)
	process_input(delta)
	process_conveyor(delta)
	process_zipline(delta)
	auto_jump()
	viewDirection()
	update_animations() 
		
	var new_velocity = velocity
	new_velocity.x = input_velocity_x + fan_push.x
	velocity = new_velocity

	move_and_slide()

	fan_push.x = clamp(fan_push.x * fan_friction, -fan_max_speed_x, fan_max_speed_x)
	fan_push.y = clamp(fan_push.y * fan_friction, -fan_max_speed_y, fan_max_speed_y)

	# Lógica para suelos normales (Bloques sólidos)
	if (current_gravity_direction > 0 and is_on_floor()) or (current_gravity_direction < 0 and is_on_ceiling()):
		trampoline_boost = false

		if has_balloon:
			has_balloon = false
			if is_instance_valid(balloon_item_ref):
				balloon_item_ref.reactivate()
			balloon_item_ref = null

func update_animations():
	# Prioridad: Zipline o Globo
	if current_zipline:
		_change_anim("Grab")
		return
	elif has_balloon:
		_change_anim("Balloon")
		return
	
	var relative_vy = velocity.y * current_gravity_direction
	var is_grounded = (current_gravity_direction > 0 and is_on_floor()) or (current_gravity_direction < 0 and is_on_ceiling())

	if is_grounded:
		_change_anim("Jump") 
	elif relative_vy < -50: 
		_change_anim("Jump")
	elif relative_vy > 50:
		_change_anim("Fall")
	else:
		_change_anim("Peak")

func _change_anim(name_anim: String) -> void:
	if current_anim != name_anim:
		current_anim = name_anim
		animated_sprite.play(name_anim)

func apply_gravity(delta):
	if current_zipline:
		return
	var final_gravity = gravity
	var fall_velocity = velocity.y + final_gravity * current_gravity_direction * delta

	if has_balloon and is_in_vertical_fan:
		var lift_force : float = -400.0 * delta * current_gravity_direction
		fall_velocity += lift_force
		
	if has_balloon:
		var fan_is_pushing_down := (current_gravity_direction > 0 and fan_push.y > 0) or (current_gravity_direction < 0 and fan_push.y < 0)
		if not fan_is_pushing_down:
			if current_gravity_direction > 0:
				fall_velocity = min(fall_velocity, max_fall_speed_with_balloon)
			else:
				fall_velocity = max(fall_velocity, -max_fall_speed_with_balloon)

	fall_velocity += fan_push.y
	velocity.y = fall_velocity

func process_input(delta):
	if current_zipline == null and current_conveyor == null:
		var input_axis = GLOBAL.get_axis().x
		var target_velocity = input_axis * max_speed
		var factor = acceleration * delta if input_axis != 0 else deceleration * delta
		input_velocity_x = lerp(input_velocity_x, target_velocity, factor)

func process_conveyor(_delta):
	if current_conveyor and not current_zipline:
		input_velocity_x = current_conveyor.direction.x * current_conveyor.conveyor_speed

func process_zipline(_delta):
	if current_zipline:
		global_position.y = current_zipline.global_position.y
		input_velocity_x = current_zipline.direction.x * current_zipline.speed
		velocity.y = 0

func auto_jump():
	if current_conveyor == null and current_zipline == null and not trampoline_boost:
		if (current_gravity_direction > 0 and is_on_floor()) or (current_gravity_direction < 0 and is_on_ceiling()):
			velocity.y = -jump_force * current_gravity_direction
			
			var tween = create_tween()
			tween.tween_property(animated_sprite, "scale", Vector2(0.8, 1.3), 0.12)
			tween.tween_property(animated_sprite, "scale", Vector2(1.0, 1.0), 0.3)

func set_fan_zone_state(state: bool) -> void:
	is_in_vertical_fan = state

# --- CAMBIO PRINCIPAL AQUÍ ---
func set_trampoline_boost(boost: bool) -> void:
	trampoline_boost = boost
	
	# Si recibimos un impulso de trampolín (boost es true), 
	# cuenta como tocar suelo, así que reventamos el globo inmediatamente.
	if boost and has_balloon:
		has_balloon = false
		if is_instance_valid(balloon_item_ref):
			balloon_item_ref.reactivate()
		balloon_item_ref = null
# -----------------------------

func _on_grab_area_area_entered(area):
	if area.is_in_group("Zipline"):
		current_zipline = area.get_parent()
		current_conveyor = null
		velocity = Vector2.ZERO
		global_position.y = current_zipline.global_position.y

func _on_grab_area_area_exited(area):
	if area.is_in_group("Zipline") and current_zipline == area.get_parent():
		var zipline = current_zipline
		var exit_side = sign(global_position.x - zipline.global_position.x)
		if exit_side == sign(zipline.direction.x):
			var impulse = zipline.direction
			if impulse.y != 0: impulse.y *= current_gravity_direction
			velocity = impulse * zipline.launch_force
		current_zipline = null

func _on_hurt_box_player_area_entered(area):
	if area.is_in_group("Hazard"):
		death_ctrl()
	elif area.is_in_group("Sticky"):
		current_conveyor = area.get_parent()
	elif area.is_in_group("EndGameArea"): 
		end_game_ctrl()
	elif area.is_in_group("Balloon"):
		has_balloon = true
		if area.get_parent().has_method("reactivate"):
			balloon_item_ref = area.get_parent()
		area.get_parent().get_node("Sprite2D").visible = false
		area.set_deferred("monitoring", false)

func _on_hurt_box_player_area_exited(area: Node):
	match area.get_groups():
		["Sticky"]: handle_conveyor_exit(area)

func handle_conveyor_exit(area):
	var conv = area.get_parent()
	if conv == current_conveyor:
		var exit_side = sign(global_position.x - conv.global_position.x)
		if exit_side == sign(conv.direction.x):
			velocity = Vector2(conv.direction.x * 150, -conv.launch_force * current_gravity_direction)
		current_conveyor = null

func _on_starting_time_timeout():
	can_move = true

func death_ctrl():
	if is_dead: 
		return
	if pcam:
			var main_camera = get_tree().get_first_node_in_group("MainCamera")
			var freeze_pos = pcam.global_position # Backup por si acaso
			if main_camera:
				freeze_pos = main_camera.global_position
			pcam.reparent(get_tree().current_scene)
			pcam.global_position = freeze_pos
			pcam.follow_mode = 0 # NONE
			pcam.follow_damping = false
	is_dead = true
	GameManager.is_dead = true
	GameManager.add_death()
	
	$CollisionPolygon2D.set_deferred("disabled", true)
	$HurtBoxPlayer/CollisionShape2D.set_deferred("disabled", true)
	$GrabArea/CollisionShape2D.set_deferred("disabled", true)
	
	velocity = Vector2.ZERO
	$AnimationPlayer.play("death")
	
	await get_tree().create_timer(0.3).timeout
	var transition = get_tree().get_first_node_in_group("Transition")
	
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - 100, 0.3).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func():
		if transition:
			transition.play_ease_out()
	)
	
	tween.tween_property(self, "global_position:y", global_position.y + 1000, 1.0).set_ease(Tween.EASE_IN)
	
	await tween.finished
	if transition:
		await transition.transition_finished
	
	GameManager.reset_scene()

func change_gravity(new_gravity_type: int, transition_time: float) -> void:
	if new_gravity_type == current_gravity_type: return
	
	var target_direction: float = 1.0 if new_gravity_type == 0 else -1.0
	var target_rotation: float = 0.0 if new_gravity_type == 0 else PI
	
	if is_changing_gravity or (is_equal_approx(current_gravity_direction, target_direction) and is_equal_approx(rotation, target_rotation)):
		return
	
	is_changing_gravity = true
	pending_gravity_type = new_gravity_type
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "current_gravity_direction", target_direction, transition_time)
	tween.tween_property(self, "rotation", target_rotation, transition_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	velocity.y *= -1
	tween.finished.connect(Callable(self, "_on_gravity_tween_finished"))

func _on_gravity_tween_finished() -> void:
	current_gravity_type = pending_gravity_type
	is_changing_gravity = false
	if current_gravity_type == 0:
		current_gravity_direction = 1.0
		rotation = 0.0
	else:
		current_gravity_direction = -1.0
		rotation = PI

func end_game_ctrl():
	if is_dead:
		return
	is_dead = true
	can_move = false
	
	velocity = Vector2.ZERO

	# Shake de cámara
	var camera = get_tree().get_first_node_in_group("MainCamera")
	if camera and camera.has_method("shake"):
		camera.shake(1.0, 1.0) # duración e intensidad

	# Reproducir animación final
	$AnimatedSprite2D.play("EndGameAnimation")
	await $AnimatedSprite2D.animation_finished 

	# Reproducir transición si existe
	var transition = get_tree().get_first_node_in_group("Transition")
	if transition:
		transition.play_ease_out()
		await transition.transition_finished

func viewDirection():
	var x_input = GLOBAL.get_axis().x
	if x_input != 0:
		$AnimatedSprite2D.flip_h = x_input < 0
		player_direction = Vector2(x_input, 0)
