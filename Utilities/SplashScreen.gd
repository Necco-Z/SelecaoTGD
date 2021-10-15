# tool, class_name and extends keywords
extends ColorRect


# built-in methods (_init, _ready and others)
func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_pressed():
		SceneControl.switch_scene("res://Stages/MainStage.tscn")
