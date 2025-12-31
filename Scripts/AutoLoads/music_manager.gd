extends Node

@export var player_path: NodePath = NodePath("AudioStreamPlayer")
@export var check_interval: float = 0.1
@onready var player: AudioStreamPlayer = get_node_or_null(player_path)

var current_track: String = ""
var fade_time := 0.5
var last_scene_name: String = ""
var _accum: float = 0.0
var is_changing_music: bool = false

var music_library := {
	"menu": preload("res://Assets/Sounds/Music/Palmtree Panic Present.mp3"),
	"world1": preload("res://Assets/Sounds/Music/Time to Learn.mp3"),
	"world2": preload("res://Assets/Sounds/Music/SRB2 OST - Tutorial.mp3"),
	"world3": preload("res://Assets/Sounds/Music/Techno Hill Zone 1.mp3"),
	"world4": preload("res://Assets/Sounds/Music/Palmtree Panic B mix.mp3"),
	"world5": preload("res://Assets/Sounds/Music/VS Black Eggman.mp3")
}

func _ready():
	if player == null:
		player = get_node_or_null(player_path)
		if player == null:
			push_error("MusicManager: No se encontró el nodo AudioStreamPlayer (revisá player_path)")
	set_process(true)
	await get_tree().process_frame
	await update_music_for_scene()

func _process(delta: float) -> void:
	_accum += delta
	if _accum < check_interval:
		return
	_accum = 0.0

	var cs := get_tree().current_scene
	if cs == null:
		return
	var scene_name := cs.name
	if scene_name != last_scene_name and not is_changing_music:
		last_scene_name = scene_name
		await update_music_for_scene()

func update_music_for_scene() -> void:
	if is_changing_music:
		return
	is_changing_music = true
	var cs := get_tree().current_scene
	if cs == null:
		is_changing_music = false
		return
	var scene_name := cs.name
	print("MusicManager: escena actual = ", scene_name)

	var lower := scene_name.to_lower()
	if lower.contains("menu") or lower.contains("selector"):
		await play_music("menu")
	elif scene_name.begins_with("Level"):
		var num_str := scene_name.replace("Level", "")
		var level_num := int(num_str)
		if level_num >= 1 and level_num <= 5:
			await play_music("world1")
		elif level_num <= 10:
			await play_music("world2")
		elif level_num <= 15:
			await play_music("world3")
		elif level_num <= 20:
			await play_music("world4")
		else:
			await play_music("world5")
	else:
		await play_music("menu")
	is_changing_music = false

func play_music(track_name: String) -> void:
	if player == null:
		return
	if current_track == track_name:
		return

	if track_name in music_library:
		print("MusicManager: cambiando música a = ", track_name)
		if player.playing:
			await fade_out()
		player.stream = music_library[track_name]
		player.volume_db = -80
		player.play()
		current_track = track_name
		await fade_in()
		print("MusicManager: música actual = ", current_track)

func stop_music() -> void:
	if player == null:
		return
	if player.playing:
		await fade_out()
		player.stop()
		current_track = ""
		print("MusicManager: música detenida")

func fade_in() -> void:
	var t := 0.0
	while t < fade_time:
		t += get_process_delta_time()
		player.volume_db = lerp(-80.0, 0.0, t / fade_time)
		await get_tree().process_frame

func fade_out() -> void:
	var t := 0.0
	while t < fade_time:
		t += get_process_delta_time()
		player.volume_db = lerp(0.0, -80.0, t / fade_time)
		await get_tree().process_frame
