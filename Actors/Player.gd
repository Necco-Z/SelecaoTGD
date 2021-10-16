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

# public variables
var is_active := true

# private variables
var _state_machine : AnimationNodeStateMachinePlayback
var _velocity := Vector2()
var _anim_state = Anim.IDLE as int
var _move_state = Move.STAND as int
var _jump_velocity: float
var _gravity: float
var _current_friction := DEFAULT_FRICTION
var _facing := Vector2.RIGHT.x
var _is_hurt := false

# onready variables
onready var sprite := $Sprite
onready var coyote_timer := $CoyoteTimer
onready var buffer_jump_timer := $BufferJumpTimer
onready var dropdown_timer := $DropdownTimer
onready var hurt_timer := $HurtTimer
onready var hit_left := $HitLeft
onready var hit_right := $HitRight
onready var dust := $Dust


# built-in methods (_init, _ready and others)
func _ready() -> void:
	# Inicializar state machine de animação
	_state_machine = $Animation/Tree.get("parameters/playback")
	$Animation/Tree.active = true

	# Definição de valores para física do personagem
	# o 0.1 a mais garante que o pulo é bem-sucedido
	jump_height = _unit_to_px(jump_height) + (float(TILE_SIZE) * 0.1)
	jump_width = _unit_to_px(jump_width)
	walk_speed = _unit_to_px(walk_speed)
	var jump_peak_width = jump_width / 2
	var jump_peak_time = jump_peak_width / walk_speed
	_jump_velocity = (2 * jump_height) / jump_peak_time
	_gravity = (2 * jump_height) / pow(jump_peak_time, 2)


func _physics_process(delta) -> void:
	_move_player(delta)
	_animate_player()


# public methods
func get_fruit() -> void:
	emit_signal("fruit_picked")


func hurt() -> void:
	if not is_active:
		return

	_is_hurt = true
	hurt_timer.start()
	yield(hurt_timer, "timeout")
	emit_signal("player_defeated")


# private methods
func _move_player(delta) -> void:
	_check_dropdown()
	_velocity.x += _get_x_movement() * walk_speed
	_velocity.x = _apply_friction(delta)
	_velocity.y = _adjust_y_velocity()
	_velocity.y -= _get_jump() * _jump_velocity
	_velocity.y += _get_gravity() * delta
	_velocity = _limit_velocity()
	_velocity = move_and_slide(_velocity, Vector2.UP)
	_check_collision()
	_set_facing()
	_set_coyote_jump()
	_set_buffer_jump()
	_set_move_state()
	_set_anim_state()


func _animate_player() -> void:
	dust.emitting = false
	if _anim_state == Anim.HURT:
		_state_machine.travel("hurt")
	elif _anim_state == Anim.RUN:
		_state_machine.travel("run")
		dust.emitting = true
	elif _anim_state == Anim.AIR:
		if _move_state == Move.JUMP:
			_state_machine.travel("jump")
		else:
			_state_machine.travel("fall")
	else:
		_state_machine.travel("idle")


func _check_dropdown() -> void:
	if Input.is_action_pressed("drop"):
		set_collision_mask_bit(ONEWAY_BIT, false)
		dropdown_timer.start()


func _get_x_movement() -> float:
	var movement := 0.0
	if Input.is_action_pressed("move_left"):
		movement -= 1
	if Input.is_action_pressed("move_right"):
		movement += 1
	if _is_hurt or not is_active:
		movement = 0
	return movement


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


func _adjust_y_velocity() -> float:
	if not coyote_timer.is_stopped() and _has_jump_input():
		return 0.0
	else:
		return _velocity.y


func _get_jump() -> float:
	if _is_hurt:
		return 0.0
	if is_on_floor():
		if _check_enemy_step().size() != 0:
			if _has_jump_input():
				return 1.1
			else:
				return 1.0
		elif _has_jump_input():
			return 1.0
	elif not coyote_timer.is_stopped() and _has_jump_input():
		return 1.0
	return 0.0


func _get_gravity() -> float:
	if not coyote_timer.is_stopped() and _has_jump_input():
		return _gravity
	elif _move_state == Move.FALL:
		return _gravity * FALL_MODIFIER
	elif not is_on_floor() and not _has_jump_input():
		return _gravity * FALL_MODIFIER
	else:
		return _gravity


func _limit_velocity() -> Vector2:
	var new_vel = _velocity
	if abs(new_vel.x) > walk_speed:
		new_vel.x = sign(new_vel.x) * walk_speed
	if abs(new_vel.y) > _jump_velocity:
		new_vel.y = sign(new_vel.y) * _jump_velocity
	return new_vel


func _check_collision() -> void:
	var c_enemy := _check_enemy_step()
	for i in get_slide_count():
		var col = get_slide_collision(i)
		if col.collider.is_in_group("enemy"):
			if c_enemy.has(col.collider):
				col.collider.hurt()
			else:
				hurt()


func _set_facing() -> void:
	if sign(_velocity.x) != 0 and _facing != sign(_velocity.x):
		_facing = int(sign(_velocity.x))
		dust.position.x = abs(dust.position.x) * _facing * -1
	sprite.flip_h = _facing == -1


func _set_coyote_jump() -> void:
	if not is_on_floor() and _move_state == Move.STAND:
		coyote_timer.start()
	elif is_on_floor() and not coyote_timer.is_stopped():
		coyote_timer.stop()


func _set_buffer_jump() -> void:
	if not is_on_floor() and Input.is_action_just_pressed("jump"):
		if coyote_timer.is_stopped() and buffer_jump_timer.is_stopped():
			buffer_jump_timer.start()


func _set_move_state() -> void:
	if is_on_floor():
		_move_state = Move.STAND
	else:
		if _velocity.y < 0:
			_move_state = Move.JUMP
		else:
			_move_state = Move.FALL


func _set_anim_state() -> void:
	if _is_hurt:
		_anim_state = Anim.HURT
	elif not is_on_floor():
		_anim_state = Anim.AIR
	elif not is_zero_approx(_velocity.x):
		_anim_state = Anim.RUN
	else:
		_anim_state = Anim.IDLE


func _check_enemy_step() -> Array:
	var result := []
	for r in [hit_left, hit_right]:
		r.force_raycast_update()
		if r.get_collider() != null:
			result.append(r.get_collider())
	return result


func _has_jump_input() -> bool:
	if not is_active:
		return false
	elif is_on_floor() and Input.is_action_just_pressed("jump"):
		return true
	elif not is_on_floor() and Input.is_action_pressed("jump"):
		return true
	elif not buffer_jump_timer.is_stopped() and is_on_floor():
		buffer_jump_timer.stop()
		return true
	else:
		return false


# helper methods
func _unit_to_px(value) -> float:
	return value * TILE_SIZE


# signal methods
func _on_DropdownTimer_timeout() -> void:
	set_collision_mask_bit(ONEWAY_BIT, true)
