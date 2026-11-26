class_name Player
extends CharacterBody2D

signal died
signal jumped(air: bool)
signal dashed

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
const DASH_BONUS_SPD := 50.0
const DASH_SUSPEND_MAX_SPD_TIME := 0.2
const DASH_COOLDOWN := 0.2

# Colors - temporary
const COLOR_NO_DASH := Color(0.9, 0.9, 0.9)
const COLOR_DASH_READY := Color(0.93, 0.27, 0.27)
const COLOR_DASH_USED := Color(0.27, 0.55, 0.93)

const RUN_FOOTSTEP_FRAMES := [1, 5]

@export var run_ref_vel := 100.0
@export var run_accel := 150.0
@export var run_decel := 10.0

@export var fly_ref_vel := 100.0
@export var fly_accel := 150.0
@export var fly_decel := 0.0

@export var movement_turn_mult := 2.0

## Falling below this y counts as death. Set by `enter_level()`.
var fall_limit := 240.0

var _facing := 1
var _can_dash := true
var _dash_cooldown := 0.0
var _suspend_max_spd_timer := 0.0
var _var_jump_timer := 0.0
var _var_jump_speed := 0.0
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _has_air_jump := false  ## A mid-air jump is still unused. Refilled on the ground.

@onready var _rect: ColorRect = $Body
@onready var _camera: Camera2D = $Camera2D
@onready var _sfx: Node = $PlayerSFX
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _run_movement: Movement = Movement.new(
	run_ref_vel, run_accel, run_decel, movement_turn_mult * run_accel
)
@onready var _fly_movement: Movement = Movement.new(
	fly_ref_vel, fly_accel, fly_decel, movement_turn_mult * fly_accel
)


func _ready() -> void:
	_sprite.frame_changed.connect(_on_sprite_frame_changed)


func kill() -> void:
	_sfx.death()
	died.emit()


func _on_sprite_frame_changed() -> void:
	if _sprite.animation == "run" and _sprite.frame in RUN_FOOTSTEP_FRAMES:
		_sfx.footstep()


func _physics_process(delta: float) -> void:
	var direction_input := _read_input()
	if direction_input.x != 0.0:
		_facing = int(direction_input.x)
	_sprite.flip_h = _facing != 1
	var jump_just_pressed := Input.is_action_just_pressed("jump")
	if jump_just_pressed:
		_jump_buffer_timer = JUMP_BUFFER_TIME
	if is_on_floor():
		_refresh_on_ground()

	if _can_dash and Input.is_action_just_pressed("dash"):
		_start_dash(direction_input)
		dashed.emit()
		_sfx.dash()
	else:
		_normal_step(delta, direction_input, jump_just_pressed)

	_tick_timers(delta)
	var was_on_floor := is_on_floor()
	move_and_slide()
	if is_on_floor() and not was_on_floor:
		_sfx.land()
	var animation := _resolve_animation()
	_sprite.play()
	if animation != _sprite.animation:
		_sprite.animation = animation

	_update_color()
	if global_position.y > fall_limit:
		kill()


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
	_suspend_max_spd_timer = maxf(_suspend_max_spd_timer - delta, 0.0)


func _update_color() -> void:
	if _can_dash:
		_rect.color = COLOR_DASH_READY
	else:
		_rect.color = COLOR_DASH_USED


func _normal_step(delta: float, input: Vector2, jump_just_pressed: bool) -> void:
	_apply_horizontal_movement(delta, input.x)
	_apply_gravity(delta)
	_apply_variable_jump(delta)
	_try_jump(jump_just_pressed)


func _apply_horizontal_movement(delta: float, direction: float) -> void:
	var movement: Movement
	if is_on_floor():
		movement = _run_movement
	else:
		movement = _fly_movement

	var accel := movement.get_accel(velocity.x, direction)
	var vel := movement.get_vel(direction)
	velocity.x = move_toward(velocity.x, vel, accel * delta)


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


func _try_jump(jump_just_pressed: bool) -> void:
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		jumped.emit(false)
		_sfx.jump()
		_jump()
	elif jump_just_pressed and _has_air_jump:
		# Needs a fresh press, so a jump buffered for landing can't use up the air jump.
		jumped.emit(true)
		_sfx.air_jump()
		_jump()
		_has_air_jump = false


func _jump() -> void:
	velocity.y = JUMP_SPD
	_var_jump_timer = JUMP_TIME
	_var_jump_speed = velocity.y
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0


func _resolve_animation() -> String:
	if is_on_floor():
		if _suspend_max_spd_timer > 0.0:
			return "dash"
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
	_can_dash = false
	_dash_cooldown = DASH_COOLDOWN
	_suspend_max_spd_timer = DASH_SUSPEND_MAX_SPD_TIME
	_var_jump_timer = 0.0
	# TODO: Fix this. Use move_toward.
	# Set the minimum speed as DASH_BONUS_SPD
	# so when you dash in the other direction you're moving,
	# the character speed becomes DASH_BONUS_SPD instantly
	velocity.x += input.x * DASH_BONUS_SPD
	_sprite.animation = "dash"
