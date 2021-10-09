# tool, class_name and extends keywords
extends Area2D

# constants
const SPEED := 120.0

# public variables
var dir := Vector2.RIGHT

# onready variables
onready var sprite := $Sprite


# built-in methods (_init, _ready and others)
func _ready():
	if dir == Vector2():
		print("ERROR: Bullet dir not defined; using right as default")
	if dir == Vector2.LEFT:
		scale.x = -1.0


func _physics_process(delta):
	global_position += SPEED * dir * delta


# private methods
func _destroy():
	# TODO: animação
	queue_free()


# signal methods
func _on_Bullet_body_entered(body: Node2D):
	_destroy()
	if body.is_in_group("player"):
		body.hit()
