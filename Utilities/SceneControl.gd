# tool, class_name and extends keywords
extends Node
# description (docstring)

# signals

# enums

# constants

# exported variables

# public variables
var current_scene : Node

# onready variables
onready var fader := $Fader


# built-in methods (_init, _ready and others)


# public methods
func switch_scene(to: PackedScene, instant := false):
	if not instant and current_scene != null:
		fader.fade_out()
		yield(fader, "fade_completed")
	else:
		fader.instant_fade_out()
	if current_scene != null:
		current_scene.queue_free()
	var _s = to.instance()
	add_child(_s)
	if not instant:
		fader.fade_in()
		yield(fader, "fade_completed")
	else:
		fader.instant_fade_in()
	current_scene = _s
