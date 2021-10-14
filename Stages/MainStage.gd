# tool, class_name and extends keywords
extends Node

# public variables
var fruits := 0
var max_fruits := 1

# onready variables
onready var player := $Player
onready var pickups := $Pickups

# for testing
onready var l_1 = $TestUI/Label1
onready var l_2 = $TestUI/Label2
onready var l_3 = $TestUI/Label3


# built-in methods (_init, _ready and others)
func _ready() -> void:
	var _c = player.connect("fruit_picked", self, "_on_fruit_picked")
	_c = player.connect("player_defeated", self, "_on_player_defeated")
	max_fruits = pickups.get_child_count()


func _physics_process(_delta) -> void:
	# for testing
	l_1.text = "State machine working: " + str(player._state_machine.is_playing())


# private methods
func _finished() -> void:
	#TODO: Add ending
	print("Congratulations!")


# signal methods
func _on_fruit_picked() -> void:
	fruits += 1
	if fruits >= max_fruits:
		_finished()


func _on_player_defeated() -> void:
	SceneControl.switch_scene("res://Stages/MainStage.tscn")

