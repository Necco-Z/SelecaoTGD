# tool, class_name and extends keywords
extends CanvasLayer

# signals
signal fade_completed

# exported variables
export (float, 0.1, 2.0) var duration = 0.5
export (int, "Ease in", "Ease out", "Ease in/out", "Ease out/in") var easing = 0
export (int, "Linear", "Sine", "Quint", "Quart", "Quad", "Expo",
		"Elastic", "Cubic", "Circle", "Bounce", "Back") var transition = 0

# onready variables
onready var fader := $ScreenFade
onready var shader := fader.material as ShaderMaterial
onready var tween := $Tween


# built-in methods (_init, _ready and others)
func _ready():
	fader.visible = false
	shader.set_shader_param("value", 0)
	shader.set_shader_param("fade_in", false)


# public methods
func fade_in():
	_fade(true)


func fade_out():
	_fade(false)


func instant_fade_in():
	fader.visible = false


func instant_fade_out():
	shader.set_shader_param("value", 1.0)
	shader.set_shader_param("fade_in", false)
	fader.visible = true


# private methods
func _fade(fade_in := true):
	var start := 0.0
	var end := 1.0
	shader.set_shader_param("fade_in", fade_in)

	shader.set_shader_param("value", start)
	tween.interpolate_property(
		shader, "shader_param/value",
		start, end, duration,
		transition, easing
	)

	fader.visible = true
	tween.start()
	yield(tween, "tween_all_completed")
	if fade_in:
		fader.visible = false
	emit_signal("fade_completed")
