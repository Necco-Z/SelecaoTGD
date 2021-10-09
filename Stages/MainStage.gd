# tool, class_name and extends keywords
extends Node

# onready variables
onready var player = $Player
onready var test_move = $TestUI/MoveState
onready var test_anim = $TestUI/AnimState
onready var test_vel = $TestUI/Velocity


# built-in methods (_init, _ready and others)
func _process(_delta):
	var _m := ""
	var _a := ""
	match player._move_state:
		0:
			_m = "STAND"
		1:
			_m = "JUMP"
		2:
			_m = "FALL"
		_:
			_m = "OTHER"
	match player._anim_state:
		0:
			_a = "IDLE"
		1:
			_a = "RUN"
		2:
			_a = "AIR"
		3:
			_a = "HIT"
		_:
			_a = "OTHER"
	test_move.text = "Move state: " + _m
	test_anim.text = "Anim state: " + _a

	var _x = str(stepify(player._velocity.x, 0.1))
	var _y = str(stepify(player._velocity.y, 0.1))
	test_vel.text = "Velocity: (" + _x + ", " + _y + ")"










