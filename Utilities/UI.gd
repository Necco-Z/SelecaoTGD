# tool, class_name and extends keywords
extends CanvasLayer

signal anim_finished

# onready variables
onready var anim_player := $AnimationPlayer


# public methods
func congratulations() -> void:
	anim_player.play("complete")
	yield(anim_player, "animation_finished")
	emit_signal("anim_finished")
