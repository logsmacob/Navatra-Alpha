extends Node
class_name CardTiltAnimation

const FAKE_3D_SHADER := preload("res://assets/shaders/fake_3d_card.gdshader")

@export var target_path: NodePath

@export_range(0.0, 20.0, 0.1) var idle_max_rotation_degrees := 3.0
@export_range(0.0, 30.0, 0.5) var idle_max_offset_pixels := 8.0
@export_range(0.1, 8.0, 0.1) var idle_float_speed := 1.1
@export_range(0.0, 20.0, 0.1) var idle_float_amount := 4.0

@export_range(0.0, 25.0, 0.1) var hover_max_y_rotation_degrees := 10.0
@export_range(0.0, 25.0, 0.1) var hover_max_x_rotation_degrees := 7.5
@export_range(0.0, 0.5, 0.01) var hover_max_shift_ratio := 0.06
@export_range(1.0, 1.5, 0.01) var hover_scale := 1.04

@export_range(1.0, 30.0, 0.1) var tilt_lerp_speed := 14.0
@export_range(1.0, 30.0, 0.1) var return_lerp_speed := 10.0

var _target: Control
var _is_hovered := false
var _rng := RandomNumberGenerator.new()

var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE

var _idle_rotation_degrees := 0.0
var _idle_offset := Vector2.ZERO
var _idle_phase := 0.0
var _time := 0.0

var _current_scale := Vector2.ONE
var _target_scale := Vector2.ONE
var _current_hover_offset := Vector2.ZERO
var _target_hover_offset := Vector2.ZERO

var _current_y_rotation := 0.0
var _target_y_rotation := 0.0
var _current_x_rotation := 0.0
var _target_x_rotation := 0.0

var _material: ShaderMaterial


func _ready() -> void:
	_target = _resolve_target()
	if _target == null:
		set_process(false)
		push_warning("CardTiltAnimation could not resolve a Control target.")
		return

	_base_position = _target.position
	_base_scale = _target.scale
	_target.pivot_offset = _target.size * 0.5

	_rng.randomize()
	_idle_rotation_degrees = _rng.randf_range(-idle_max_rotation_degrees, idle_max_rotation_degrees)
	_idle_offset = Vector2(
		_rng.randf_range(-idle_max_offset_pixels, idle_max_offset_pixels),
		_rng.randf_range(-idle_max_offset_pixels, idle_max_offset_pixels)
	)
	_idle_phase = _rng.randf() * TAU

	_material = ShaderMaterial.new()
	_material.shader = FAKE_3D_SHADER
	_target.material = _material

	_current_scale = _base_scale
	_target_scale = _base_scale
	_apply_transform()
	_apply_shader_rotation(0.0, 0.0)

	set_process(true)


func _process(delta: float) -> void:
	if _target == null:
		return

	_time += delta

	if _is_hovered:
		_update_hover_targets()
	else:
		_target_scale = _base_scale
		_target_hover_offset = Vector2.ZERO
		_target_y_rotation = 0.0
		_target_x_rotation = 0.0

	var speed := tilt_lerp_speed if _is_hovered else return_lerp_speed
	var weight := clampf(speed * delta, 0.0, 1.0)

	_current_scale = _current_scale.lerp(_target_scale, weight)
	_current_hover_offset = _current_hover_offset.lerp(_target_hover_offset, weight)
	_current_y_rotation = lerpf(_current_y_rotation, _target_y_rotation, weight)
	_current_x_rotation = lerpf(_current_x_rotation, _target_x_rotation, weight)

	_apply_transform()
	_apply_shader_rotation(_current_y_rotation, _current_x_rotation)


func _on_item_button_mouse_entered() -> void:
	_is_hovered = true


func _on_item_button_mouse_exited() -> void:
	_is_hovered = false


func _resolve_target() -> Control:
	if target_path != NodePath():
		return get_node_or_null(target_path) as Control
	return get_parent() as Control


func _update_hover_targets() -> void:
	var local_mouse := _target.get_local_mouse_position()
	var size := _target.size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var normalized_x := clampf((local_mouse.x / size.x) * 2.0 - 1.0, -1.0, 1.0)
	var normalized_y := clampf((local_mouse.y / size.y) * 2.0 - 1.0, -1.0, 1.0)

	_target_y_rotation = normalized_x * hover_max_y_rotation_degrees
	_target_x_rotation = -normalized_y * hover_max_x_rotation_degrees

	_target_scale = _base_scale * hover_scale
	var max_shift := size * hover_max_shift_ratio
	_target_hover_offset = Vector2(normalized_x * max_shift.x, normalized_y * max_shift.y)


func _apply_transform() -> void:
	var float_offset := Vector2(
		sin(_time * idle_float_speed + _idle_phase) * idle_float_amount,
		cos(_time * (idle_float_speed * 0.8) + _idle_phase) * idle_float_amount
	)
	_target.rotation_degrees = _idle_rotation_degrees
	_target.scale = _current_scale
	_target.position = _base_position + _idle_offset + float_offset + _current_hover_offset


func _apply_shader_rotation(y_rotation: float, x_rotation: float) -> void:
	if _material == null:
		return
	_material.set_shader_parameter("y_rot", y_rotation)
	_material.set_shader_parameter("x_rot", x_rotation)
