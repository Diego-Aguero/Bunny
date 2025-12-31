extends CanvasLayer

@onready var fps_label: Label = $FPSLabel
@onready var deaths_label: Label = $DeathsLabel
@onready var time_label: Label = $TimeLabel
@onready var timer: Timer = $Timer

var scenes_without_hud := [
	"TitleScreen",
	"MainMenu",
	"LevelSelector"
]

var elapsed_time := 0.0  # tiempo acumulado del Timer

func _ready():
	layer = 100  # para estar encima de todo
	# conectamos para saber cuando entra una nueva escena
	get_tree().root.child_entered_tree.connect(_on_scene_changed)
	_on_scene_changed(get_tree().current_scene)

func _on_scene_changed(new_scene):
	# revisamos que sea la escena principal
	if new_scene != get_tree().current_scene or not new_scene:
		return

	if new_scene.name in scenes_without_hud:
		hide()
		timer.stop()
	else:
		show()
		if new_scene.name == "EndScreen":
			timer.stop()
		else:
			timer.start()  # iniciamos Timer si es un nivel normal

func _process(delta):
	# Actualizamos FPS y muertes
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	deaths_label.text = "Deaths: %d" % GameManager.death_count
	
	# Actualizamos el tiempo acumulado solo si el Timer está activo
	if timer.is_stopped() == false:
		elapsed_time += delta
	
	# Convertimos a minutos y segundos
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60

	
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]
