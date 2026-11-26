class_name Movement

var _ref_vel: float
var _accel: float
var _decel: float
var _turn_accel: float


func _init(ref_vel: float, accel: float, decel: float, turn_accel: float = -1.0) -> void:
	_ref_vel = ref_vel
	_accel = accel
	_decel = decel
	_turn_accel = turn_accel
	if _turn_accel < 0:
		_turn_accel = _accel


func get_accel(velocity: float, direction: float) -> float:
	if absf(velocity) > _ref_vel and direction == signf(velocity):
		return _decel
	if direction != signf(velocity):
		return _turn_accel
	return _accel


func get_vel(direction: float) -> float:
	return _ref_vel * direction
