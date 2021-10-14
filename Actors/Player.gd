# tool, class_name and extends keywords
extends KinematicBody2D
# description (docstring)

# signals
signal fruit_picked
signal player_defeated

# enums
enum Anim {IDLE, RUN, AIR, HURT}
enum Move {STAND, JUMP, FALL}

# constants
const TILE_SIZE = 16
const FALL_MODIFIER := 1.5
const DEFAULT_FRICTION := 6.0
const ONEWAY_BIT := 6

# exported variables
export (float, 0.5, 10.0, 0.5) var jump_height = 1
export (float, 0.5, 20, 0.5) var jump_width = 1
export (float, 0.5, 20, 0.5) var walk_speed = 1
export (float, 0.0, 1, 0.1) var coyote_time = 0.2
export (float, 0.0, 1, 0.1) var buffer_jump_time = 0.2

# public variables
var can_move := true

# private variables
var _state_machine : AnimationNodeStateMachinePlayback
var _velocity := Vector2()
var _anim_state = Anim.IDLE as int
var _move_state = Move.STAND as int
var _jump_velocity: float
var _gravity: float
var _current_friction := DEFAULT_FRICTION
var _facing := Vector2.RIGHT.x

# onready variables
onready var _coyote_timer := $CoyoteTimer
onready var _buffer_jump_timer := $BufferJumpTimer
onready var _sprite := $Sprite
onready var _dropdown_timer := $DropdownTimer
onready var _hit_left := $HitLeft
onready var _hit_right := $HitRight


# built-in methods (_init, _ready and others)
func _ready() -> void:
	# Inicializar state machine de animação
	_state_machine = $Animation/Tree.get("parameters/playback")
	$Animation/Tree.active = true

	# Definição de valores para física do personagem
	# o quarto a mais garante que o pulo é bem-sucedido
	jump_height = _unit_to_px(jump_height) + (float(TILE_SIZE) / 4)
	jump_width = _unit_to_px(jump_width)
	walk_speed = _unit_to_px(walk_speed)
	var jump_peak_width = jump_width / 2
	var jump_peak_time = jump_peak_width / walk_speed
	_jump_velocity = (2 * jump_height) / jump_peak_time
	_gravity = (2 * jump_height) / pow(jump_peak_time, 2)
	_coyote_timer.wait_time = coyote_time
	_buffer_jump_timer.wait_time = buffer_jump_time


func _process(_delta) -> void:
	pass


func _physics_process(delta) -> void:
	if can_move:
		_move_player(delta)
	_animate_player()


# public methods
func get_fruit() -> void:
	emit_signal("fruit_picked")


func hurt() -> void:
	emit_signal("player_defeated")


# private methods
func _move_player(delta) -> void:
	_check_dropdown()
	_velocity.x += _get_x_movement() * walk_speed
	_velocity.x = _apply_friction(delta)
	_velocity.y -= _get_jump() * _jump_velocity
	_velocity.y += _get_gravity() * delta
	_velocity = _limit_velocity()
	_velocity = move_and_slide(_velocity, Vector2.UP)
	_check_collision()
	_set_facing()
	_set_move_state()
	_set_anim_state()
	_set_coyote_jump()
	_set_buffer_jump()


func _animate_player() -> void:
	if _anim_state == Anim.HURT:
		print("woo!")
		_state_machine.travel("hurt")
	elif _anim_state == Anim.RUN:
		_state_machine.travel("run")
	elif _anim_state == Anim.AIR:
		if _move_state == Move.JUMP:
			_state_machine.travel("jump")
		else:
			_state_machine.travel("fall")
	else:
		_state_machine.travel("idle")


func _check_collision() -> void:
	var c_enemy := _check_enemy_step()
	for i in get_slide_count():
		var col = get_slide_collision(i)
		if col.collider.is_in_group("enemy"):
			if c_enemy.has(col.collider):
				col.collider.hurt()
			else:
				hurt()


func _check_enemy_step() -> Array:
	var result := []
	for r in [_hit_left, _hit_right]:
		r.force_raycast_update()
		if r.get_collider() != null:
			result.append(r.get_collider())
	return result


func _check_dropdown() -> void:
	if Input.is_action_pressed("drop"):
		set_collision_mask_bit(ONEWAY_BIT, false)
		_dropdown_timer.start()


func _get_x_movement() -> float:
	var movement := 0.0
	if Input.is_action_pressed("move_left"):
		movement -= 1
	if Input.is_action_pressed("move_right"):
		movement += 1
	return movement


func _get_jump() -> float:
	if is_on_floor():
		if _check_enemy_step().size() != 0:
			if _has_jump_input():
				return 1.1
			else:
				return 1.0
		elif _has_jump_input():
			return 1.0
	elif (_coyote_timer.is_stopped() == false
			and Input.is_action_just_pressed("jump")):
		return 1.0
	return 0.0


func _has_jump_input() -> bool:
	if Input.is_action_just_pressed("jump"):
		return true
	elif _buffer_jump_timer.is_stopped() == false:
		return true
	elif Input.is_action_pressed("jump") and _check_enemy_step().size() != 0:
		return true
	else:
		return false


func _get_gravity() -> float:
	if _move_state == Move.FALL or not Input.is_action_pressed("jump"):
		return _gravity * FALL_MODIFIER
	else:
		return _gravity


func _limit_velocity() -> Vector2:
	var new_vel = _velocity
	if abs(new_vel.x) > walk_speed:
		new_vel.x = sign(new_vel.x) * walk_speed
	if new_vel.y > _jump_velocity:
		new_vel.y = _jump_velocity
	return new_vel


func _apply_friction(delta) -> float:
	var xlen = abs(_velocity.x)
	var xsign = sign(_velocity.x)
	var applied_friction: float
	if is_on_floor():
		applied_friction = _current_friction
	else:
		applied_friction = _current_friction / 2
	if _get_x_movement() == 0:
		xlen = max(0, xlen - walk_speed * applied_friction * delta)
	return xlen * xsign


func _set_facing() -> void:
	if sign(_velocity.x) != 0 and _facing != sign(_velocity.x):
		_facing = int(sign(_velocity.x))
	_sprite.flip_h = _facing == -1


func _set_coyote_jump() -> void:
	if not is_on_floor() and _move_state == Move.STAND:
		_move_state = Move.FALL
		_coyote_timer.start()


func _set_buffer_jump() -> void:
	if not is_on_floor():
		if _coyote_timer.is_stopped() and _buffer_jump_timer.is_stopped():
			if Input.is_action_just_pressed("jump"):
				_buffer_jump_timer.start()


func _set_move_state() -> void:
	if is_on_floor():
		_move_state = Move.STAND
	else:
		if _velocity.y < 0:
			_move_state = Move.JUMP
		else:
			_move_state = Move.FALL


func _set_anim_state() -> void:
	# OBS: Adicionar estado HURT

	if not is_on_floor():
		_anim_state = Anim.AIR
	elif not is_zero_approx(_velocity.x):
		_anim_state = Anim.RUN
	else:
		_anim_state = Anim.IDLE


# helper methods
func _unit_to_px(value) -> float:
	return value * TILE_SIZE


func _on_DropdownTimer_timeout() -> void:
	set_collision_mask_bit(ONEWAY_BIT, true)
