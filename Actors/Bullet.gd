# tool, class_name and extends keywords
extends Area2D

# constants
const SPEED := 30.0

# private variables
var _dir := Vector2.RIGHT


# built-in methods (_init, _ready and others)
func _init(dir: Vector2):
	if dir != Vector2():
		_dir = dir


func _physics_process(delta):
	global_position += SPEED * _dir * delta


# private methods
func _destroy():
	# TODO: animação
	queue_free()


# signal methods
func _on_Bullet_body_entered(body: Node2D):
	_destroy()
	if body.is_in_group("player"):
		body.hit()
