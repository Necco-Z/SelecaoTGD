# tool, class_name and extends keywords
extends KinematicBody2D
# description (docstring)

# signals

# enums
enum States {PATROL, ALERT, HURT}

# constants
const BULLET = preload("res://Actors/Bullet.tscn")
const SPEED = 40.0

# exported variables
export (String, "Right", "Left") var start_facing = "Right"
export (NodePath) var game_space_node

# public variables
var is_active := true

# private variables
var _state_machine : AnimationNodeStateMachinePlayback
var _state = States.PATROL
var _direction := Vector2.RIGHT
var _can_run := true
var _game_space : Node

# onready variables
onready var shoot_pos := $ShootPos
onready var floor_detect := $FloorDetect
onready var wall_detect := $WallDetect
onready var run_check_timer := $RunCheckTimer
onready var alert_timer := $AlertTimer
onready var shoot_timer := $ShootTimer
onready var patrol_timer := $PatrolTimer
onready var sprite := $Sprite
onready var player_detect := $PlayerDetect


# built-in methods (_init, _ready and others)
func _ready() -> void:
	_state_machine = $Animation/Tree.get("parameters/playback")
	$Animation/Tree.active = true

	if game_space_node == "":
		_game_space = get_parent()
	else:
		_game_space = get_node(game_space_node)

	if start_facing == "Left":
		_flip_dir()


func _physics_process(_delta: float) -> void:
	_execute_state()
	_animate()

# public methods
func hurt() -> void:
	is_active = false
	_state = States.HURT


# private methods
func _execute_state() -> void:
	match _state:
		States.PATROL:
			if player_detect.is_colliding():
				patrol_timer.stop()
				_state = States.ALERT
			elif _can_run:
				_run()
			elif patrol_timer.is_stopped():
				patrol_timer.start()
		States.ALERT:
			if not player_detect.is_colliding():
				if alert_timer.is_stopped():
					alert_timer.start()
			else:
				alert_timer.stop()
		States.HURT:
			pass


func _animate() -> void:
	match _state:
		States.PATROL:
			if patrol_timer.is_stopped():
				_state_machine.travel("run")
			else:
				_state_machine.travel("idle")
		States.ALERT:
			if shoot_timer.is_stopped():
				_state_machine.travel("attack")
			else:
				_state_machine.travel("idle")
		States.HURT:
			_state_machine.travel("hurt")



func _shoot() -> void:
	var pos = shoot_pos.global_position
	var _b = BULLET.instance()
	_b.dir = _direction
	_game_space.add_child(_b)
	_b.global_position = pos
	shoot_timer.start()


func _run() -> void:
	var _c = move_and_slide(_direction * SPEED, Vector2.UP)


func _flip_dir() -> void:
	_direction.x *= -1
	shoot_pos.position.x *= -1
	player_detect.cast_to.x *= -1
	floor_detect.position.x *= -1
	wall_detect.position.x *= -1
	if _direction == Vector2.LEFT:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	_can_run = true
	run_check_timer.start()


func _check_run() -> void:
	var value = true
	if floor_detect.get_overlapping_bodies().size() == 0:
		value = false
	if wall_detect.get_overlapping_bodies().size() != 0:
		value = false
	_can_run = value


# signal methods
func _on_PatrolTimer_timeout() -> void:
	if _state == States.PATROL:
		_flip_dir()


func _on_RunCheckTimer_timeout() -> void:
	if is_active:
		_check_run()


func _on_AlertTimer_timeout() -> void:
	if _state == States.ALERT:
		_state = States.PATROL
