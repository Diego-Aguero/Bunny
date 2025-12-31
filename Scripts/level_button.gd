extends HBoxContainer

@export var level_scene_path = ""
@export var level_number: String

func _ready():
	$TextureButton.connect("pressed", Callable(self, "_on_pressed"))
	$TextureButton/LabelLevel.text = level_number

func _on_pressed():
	if level_scene_path != "":
		get_tree().change_scene_to_file(level_scene_path)
	else:
		push_error("No se definió la ruta del nivel")
