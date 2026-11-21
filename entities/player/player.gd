class_name Player
extends CharacterBody2D

signal died

# X axis movement
# Running
const RUN_MAX_SPD := 90.0
const RUN_ACCEL := 1000.0
const RUN_OVER_MAX_DECEL := 400.0

# Flying
const FLY_MAX_SPD := 120.0
const FLY_ACCEL := 1000.0
const FLY_OVER_MAX_DECEL := 400.0

# Y axis movement
# Falling
const FALL_MAX_SPD := 160.0
const FALL_MARGIN := 60.0  ## How far below the level counts as death.

# Gravity
const GRAVITY_ACCEL := 900.0
const GRAVITY_HALF_THRESHOLD := 40.0  ## Below this vertical speed...
const GRAVITY_APEX_MULT := 0.5  ## ...holding jump halves gravity: a floaty apex.

# Jumping
const JUMP_SPD := -105.0
const JUMP_HORIZONTAL_BOOST := 30.0  ## Extra horizontal speed when jumping while moving.
const JUMP_TIME := 0.2  ## Holding jump keeps full upward speed this long.
const JUMP_COYOTE_TIME := 0.1  ## Can still jump this long after walking off a ledge.
const JUMP_BUFFER_TIME := 0.1  ## A jump pressed this early before landing still counts.

# Dashing
const DASH_SPD := 240.0
const DASH_END_SPD := 160.0
const DASH_VERTICAL_MULT := 0.75
const DASH_TIME := 0.2
const DASH_COOLDOWN := 0.2

# Colors - temporary
const COLOR_NO_DASH := Color(0.9, 0.9, 0.9)
const COLOR_DASH_READY := Color(0.93, 0.27, 0.27)
const COLOR_DASH_USED := Color(0.27, 0.55, 0.93)

## Falling below this y counts as death. Set by `enter_level()`.
var fall_limit := 240.0

var _facing := 1
var _can_dash := true
var _dash_timer := 0.0
var _dash_cooldown := 0.0
var _dash_direction := Vector2.ZERO
var _var_jump_timer := 0.0
var _var_jump_speed := 0.0
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _has_air_jump := false  ## A mid-air jump is still unused. Refilled on the ground.

@onready var _rect: ColorRect = $Body
@onready var _camera: Camera2D = $Camera2D
@onready var _sfx: Node = $PlayerSFX


func _physics_process(delta: float) -> void:
	var direction_input := _read_input()
	if direction_input.x != 0.0:
		_facing = int(direction_input.x)
	$AnimatedSprite2D.flip_h = _facing != 1
	var jump_just_pressed := Input.is_action_just_pressed("jump")
	if jump_just_pressed:
		_jump_buffer_timer = JUMP_BUFFER_TIME
	if is_on_floor():
		_refresh_on_ground()

	if _dash_timer > 0.0:
		_dash_step(delta)
	elif _can_dash and Input.is_action_just_pressed("dash"):
		_start_dash(direction_input)
		_sfx.dash()
	else:
		_normal_step(delta, direction_input, jump_just_pressed)

	_tick_timers(delta)
	move_and_slide()
	var animation := _resolve_animation()
	$AnimatedSprite2D.play()
	if animation != $AnimatedSprite2D.animation:
		$AnimatedSprite2D.animation = animation

	_update_color()
	if global_position.y > fall_limit:
		died.emit()


## Prepares the player for `level`: abilities, camera limits, and a fresh start.
func enter_level(level: Level) -> void:
	fall_limit = level.size.y + FALL_MARGIN

	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = level.size.x
	_camera.limit_bottom = level.size.y
	respawn(level.spawn.global_position)


## Puts the player at `pos` with a clean movement state.
func respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_dash_timer = 0.0
	_dash_cooldown = 0.0
	_var_jump_timer = 0.0
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_can_dash = true
	_has_air_jump = true
	_camera.reset_smoothing()


## Movement input as a digital -1/0/1 per axis.
func _read_input() -> Vector2:
	return Vector2(
		signf(Input.get_axis("move_left", "move_right")),
		signf(Input.get_axis("move_up", "move_down"))
	)


func _refresh_on_ground() -> void:
	_coyote_timer = JUMP_COYOTE_TIME
	_has_air_jump = true
	if _dash_cooldown <= 0.0:
		_can_dash = true


func _tick_timers(delta: float) -> void:
	_dash_cooldown = maxf(_dash_cooldown - delta, 0.0)
	_coyote_timer = maxf(_coyote_timer - delta, 0.0)
	_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _update_color() -> void:
	if _can_dash:
		_rect.color = COLOR_DASH_READY
	else:
		_rect.color = COLOR_DASH_USED


func _normal_step(delta: float, input: Vector2, jump_just_pressed: bool) -> void:
	_apply_horizontal_movement(delta, input.x)
	_apply_gravity(delta)
	_apply_variable_jump(delta)
	_try_jump(input.x, jump_just_pressed)


func _apply_horizontal_movement(delta: float, direction: float) -> void:
	var accel: float
	var max_spd: float
	var over_max_decel: float
	if is_on_floor():
		accel = RUN_ACCEL
		max_spd = RUN_MAX_SPD
		over_max_decel = RUN_OVER_MAX_DECEL
	else:
		accel = FLY_ACCEL
		max_spd = FLY_MAX_SPD
		over_max_decel = FLY_OVER_MAX_DECEL

	if absf(velocity.x) > max_spd and signf(velocity.x) == direction:
		accel = over_max_decel

	velocity.x = move_toward(velocity.x, direction * max_spd, accel * delta)


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var gravity := GRAVITY_ACCEL
	if absf(velocity.y) <= GRAVITY_HALF_THRESHOLD and Input.is_action_pressed("jump"):
		gravity *= GRAVITY_APEX_MULT
	velocity.y = move_toward(velocity.y, FALL_MAX_SPD, gravity * delta)


## While jump is held (right after taking off) we keep the full takeoff speed instead of
## letting gravity slow us down. Releasing early cuts the jump short.
func _apply_variable_jump(delta: float) -> void:
	if _var_jump_timer <= 0.0:
		return
	if Input.is_action_pressed("jump") and not is_on_ceiling():
		velocity.y = minf(velocity.y, _var_jump_speed)
		_var_jump_timer -= delta
	else:
		_var_jump_timer = 0.0


func _try_jump(direction: float, jump_just_pressed: bool) -> void:
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		_sfx.jump()
		_jump(direction)
	elif jump_just_pressed and _has_air_jump:
		# Needs a fresh press, so a jump buffered for landing can't use up the air jump.
		_sfx.jump()
		_jump(direction)
		_has_air_jump = false


func _jump(direction: float) -> void:
	velocity.y = JUMP_SPD
	velocity.x += JUMP_HORIZONTAL_BOOST * direction
	_var_jump_timer = JUMP_TIME
	_var_jump_speed = velocity.y
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0


func _resolve_animation() -> String:
	if _dash_timer > 0.0:
		return "dash"
	if is_on_floor():
		if velocity.x == 0.0:
			return "idle"
		return "run"
	if velocity.y >= -1.0 and velocity.y <= 1.0:
		return "float"
	if velocity.y > 0:
		return "descend"
	if velocity.y < 0:
		return "ascend"
	return "idle"


func _start_dash(input: Vector2) -> void:
	# 8 directions; with no direction held, dash the way we are facing.
	_dash_direction = input.normalized() if input != Vector2.ZERO else Vector2(_facing, 0)
	_can_dash = false
	_dash_timer = DASH_TIME
	_dash_cooldown = DASH_COOLDOWN
	_var_jump_timer = 0.0
	velocity = _dash_direction * DASH_SPD
	$AnimatedSprite2D.animation = "dash"


## During a dash we ignore input and gravity: the velocity is fixed until the timer ends.
func _dash_step(delta: float) -> void:
	_dash_timer -= delta
	velocity = _dash_direction * DASH_SPD
	if _dash_timer <= 0.0:
		velocity = _dash_direction * DASH_END_SPD
		if _dash_direction.y < 0.0:
			velocity.y *= DASH_VERTICAL_MULT
