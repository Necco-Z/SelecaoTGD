# tool, class_name and extends keywords
extends Node

# onready variables
onready var enemy = $Enemy
onready var l_1 = $TestUI/Label1
onready var l_2 = $TestUI/Label2
onready var l_3 = $TestUI/Label3


# built-in methods (_init, _ready and others)
func ready():
	pass


func _process(_delta):
	var _s = "OTHER"
	match enemy._state:
		0:
			_s = "PATROL"
		1:
			_s = "ALERT"
		2:
			_s = "HIT"

	l_1.text = "Enemy state: " + _s

	l_2.text = "Enemy can run? " + str(enemy._can_run)








