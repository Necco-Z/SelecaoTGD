extends Camera2D

export(NodePath) var target_node

var target: Node2D


# default functions
func _ready():
	target = get_node_or_null(target_node)


func _process(_delta):
	if target != null:
		global_position = target.global_position
