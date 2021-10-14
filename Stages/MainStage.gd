# tool, class_name and extends keywords
extends Node

# public variables
var fruits := 0
var max_fruits := 1

# onready variables
onready var player := $Player
onready var pickups := $Pickups
onready var ui := $UI


# built-in methods (_init, _ready and others)
func _ready() -> void:
	var _c = player.connect("fruit_picked", self, "_on_fruit_picked")
	_c = player.connect("player_defeated", self, "_on_player_defeated")
	max_fruits = pickups.get_child_count()


# private methods
func _finished() -> void:
	player.is_active = false
	ui.congratulations()
	yield(ui, "anim_finished")
	_reset()


func _reset() -> void:
	SceneControl.switch_scene("res://Stages/MainStage.tscn")


# signal methods
func _on_fruit_picked() -> void:
	fruits += 1
	if fruits >= max_fruits:
		_finished()


func _on_player_defeated() -> void:
	_reset()

