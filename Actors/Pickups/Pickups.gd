# tool, class_name and extends keywords
extends Area2D

# onready variables
onready var anim_player := $AnimationPlayer


# private methods
func send_pickup(body: Node) -> void:
	set_deferred("monitorable", false)
	body.get_fruit()
	anim_player.play("collected")
	yield(anim_player, "animation_finished")
	queue_free()


# signal methods
func _on_body_entered(body: Node) -> void:
	send_pickup(body)
