extends TextureButton

class_name CarouselButton
@export var scene_path = ""

func _ready():
	self.connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("No se definió la ruta de la escena")
