extends Button

@export var path: String = ""

func _ready():
	if !FileAccess.file_exists(path):
		printerr("Cannot find: \"", path, "\" in file system!")
		return
		
	connect("pressed", change_scene)
	
func change_scene():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file(path)
	
