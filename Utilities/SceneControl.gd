# tool, class_name and extends keywords
extends Node

# public variables
var current_scene : Node
var is_switching := false

# onready variables
onready var fader := $Fader


# built-in methods (_init, _ready and others)
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


# public methods
func switch_scene(to: String, instant := false):
	if is_switching:
		return

	is_switching = true
	if not instant and current_scene != null:
		fader.fade_out()
		yield(fader, "fade_completed")
	else:
		fader.instant_fade_out()
	if current_scene != null:
		current_scene.queue_free()
	var _s = load(to).instance()
	add_child(_s)
	if not instant:
		fader.fade_in()
		yield(fader, "fade_completed")
	else:
		fader.instant_fade_in()
	current_scene = _s
	is_switching = false
