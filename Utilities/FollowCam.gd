# tool, class_name and extends keywords
extends Camera2D

# exported variables
export(NodePath) var target_node

# private variables
var _target: Node2D


# built-in methods (_init, _ready and others)
func _ready():
	_target = get_node_or_null(target_node)


func _process(_delta):
	if _target != null:
		global_position = _target.global_position
