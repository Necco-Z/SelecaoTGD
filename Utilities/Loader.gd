# tool, class_name and extends keywords
extends Node

# exported variables
export (String, FILE, "*.tscn") var starter_scene


# built-in methods (_init, _ready and others)
func _ready() -> void:
	SceneControl.switch_scene(starter_scene, true)
	queue_free()
