extends Node
class_name CardTiltAnimation

@export var target_path: NodePath

@export_range(0.0, 25.0, 0.1) var idle_max_rotation_degrees := 5.0
@export_range(0.0, 50.0, 0.5) var idle_max_offset_pixels := 10.0

@export_range(0.0, 30.0, 0.1) var hover_max_rotation_degrees := 8.0
@export_range(0.0, 1.0, 0.01) var hover_max_skew := 0.15
@export_range(0.0, 0.5, 0.01) var hover_max_shift_ratio := 0.08
@export_range(1.0, 1.5, 0.01) var hover_scale := 1.03

@export_range(1.0, 30.0, 0.1) var tilt_lerp_speed := 12.0
@export_range(1.0, 30.0, 0.1) var return_lerp_speed := 10.0

var _target: Control
var _is_hovered := false
var _rng := RandomNumberGenerator.new()

var _base_rotation_degrees := 0.0
var _base_position := Vector2.ZERO

var _idle_rotation_degrees := 0.0
var _idle_offset := Vector2.ZERO

var _current_rotation_degrees := 0.0
var _target_rotation_degrees := 0.0

var _current_skew := 0.0
var _target_skew := 0.0

var _current_scale := Vector2.ONE
var _target_scale := Vector2.ONE

var _current_hover_offset := Vector2.ZERO
var _target_hover_offset := Vector2.ZERO


func _ready() -> void:
	_target = _resolve_target()
	if _target == null:
		set_process(false)
		push_warning("CardTiltAnimation could not resolve a Control target.")
		return

	_base_rotation_degrees = _target.rotation_degrees
	_base_position = _target.position
	_target.pivot_offset = _target.size * 0.5

	_rng.randomize()
	_idle_rotation_degrees = _rng.randf_range(-idle_max_rotation_degrees, idle_max_rotation_degrees)
	_idle_offset = Vector2(
		_rng.randf_range(-idle_max_offset_pixels, idle_max_offset_pixels),
		_rng.randf_range(-idle_max_offset_pixels, idle_max_offset_pixels)
	)

	_current_rotation_degrees = _base_rotation_degrees + _idle_rotation_degrees
	_target_rotation_degrees = _current_rotation_degrees
	_current_skew = _target.skew
	_target_skew = _current_skew
	_current_scale = _target.scale
	_target_scale = _current_scale

	_apply_transform()
	set_process(true)


func _process(delta: float) -> void:
	if _target == null:
		return

	if _is_hovered:
		_update_hover_targets()
	else:
		_target_rotation_degrees = _base_rotation_degrees + _idle_rotation_degrees
		_target_skew = 0.0
		_target_scale = Vector2.ONE
		_target_hover_offset = Vector2.ZERO

	var speed := tilt_lerp_speed if _is_hovered else return_lerp_speed
	var t := clamp(speed * delta, 0.0, 1.0)

	_current_rotation_degrees = lerpf(_current_rotation_degrees, _target_rotation_degrees, t)
	_current_skew = lerpf(_current_skew, _target_skew, t)
	_current_scale = _current_scale.lerp(_target_scale, t)
	_current_hover_offset = _current_hover_offset.lerp(_target_hover_offset, t)

	_apply_transform()


func _on_item_button_mouse_entered() -> void:
	_is_hovered = true


func _on_item_button_mouse_exited() -> void:
	_is_hovered = false


func _resolve_target() -> Control:
	if target_path != NodePath():
		return get_node_or_null(target_path) as Control
	return get_parent() as Control


func _update_hover_targets() -> void:
	var local_mouse: Vector2 = _target.get_local_mouse_position()
	var size := _target.size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var normalized_x := clampf((local_mouse.x / size.x) * 2.0 - 1.0, -1.0, 1.0)
	var normalized_y := clampf((local_mouse.y / size.y) * 2.0 - 1.0, -1.0, 1.0)

	_target_rotation_degrees = _base_rotation_degrees + _idle_rotation_degrees + normalized_x * hover_max_rotation_degrees
	_target_skew = normalized_y * hover_max_skew
	_target_scale = Vector2.ONE * hover_scale

	var max_shift = size * hover_max_shift_ratio
	_target_hover_offset = Vector2(normalized_x * max_shift.x, normalized_y * max_shift.y)


func _apply_transform() -> void:
	_target.rotation_degrees = _current_rotation_degrees
	_target.skew = _current_skew
	_target.scale = _current_scale
	_target.position = _base_position + _idle_offset + _current_hover_offset
