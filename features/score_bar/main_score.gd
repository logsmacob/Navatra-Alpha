extends PanelContainer
class_name MainScore

const DEFAULT_HAND_TYPE_TITLE := "Hand Type:"
const DEFAULT_HAND_TYPE_VALUE := "-"
const VALUE_ANIMATION_DURATION_SECONDS := 0.2

@export var _quota_label: Label
@export var _hand_type_label: Label
@export var _hand_type_value_label: Label
@export var _base_label: Label
@export var _mult_label: Label
@export var _result_label: Label

var _display_quota: float = 0.0
var _display_base: float = 0.0
var _display_mult: float = 0.0
var _display_result: float = 0.0

var _quota_tween: Tween
var _base_tween: Tween
var _mult_tween: Tween
var _result_tween: Tween

func _ready() -> void:
	_display_quota = _read_label_value(_quota_label)
	_display_base = _read_label_value(_base_label)
	_display_mult = _read_label_value(_mult_label)
	_display_result = _read_label_value(_result_label)
	_refresh_all_labels()

func set_quota(value: int, instant: bool = false) -> void:
	_animate_value(&"_display_quota", float(value), _quota_label, _quota_tween, instant)

func set_hand_type(value: String) -> void:
	_hand_type_value_label.text = value

func set_base(value: int, instant: bool = false) -> void:
	_animate_value(&"_display_base", float(value), _base_label, _base_tween, instant)

func set_mult(value: int, instant: bool = false) -> void:
	_animate_value(&"_display_mult", float(value), _mult_label, _mult_tween, instant)

func set_result(value: int, instant: bool = false) -> void:
	_animate_value(&"_display_result", float(value), _result_label, _result_tween, instant)

func reset_math_display() -> void:
	_hand_type_label.text = DEFAULT_HAND_TYPE_TITLE
	set_hand_type(DEFAULT_HAND_TYPE_VALUE)
	zero_math_display()

func zero_math_display() -> void:
	set_base(0, true)
	set_mult(0, true)
	set_result(0, true)

func _set_hand_type_color(color: Color) -> void:
	_hand_type_label.modulate = color
	_hand_type_value_label.modulate = color

func _refresh_all_labels() -> void:
	_write_label_value(_quota_label, _display_quota)
	_write_label_value(_base_label, _display_base)
	_write_label_value(_mult_label, _display_mult)
	_write_label_value(_result_label, _display_result)

func _animate_value(
	property_name: StringName,
	target_value: float,
	label: Label,
	tween: Tween,
	instant: bool
) -> void:
	if tween != null and tween.is_running():
		tween.kill()

	if instant:
		set(property_name, target_value)
		_write_label_value(label, target_value)
		return

	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(_update_animated_label.bind(property_name, label), get(property_name), target_value, VALUE_ANIMATION_DURATION_SECONDS)
	if property_name == &"_display_quota":
		_quota_tween = tween
	elif property_name == &"_display_base":
		_base_tween = tween
	elif property_name == &"_display_mult":
		_mult_tween = tween
	else:
		_result_tween = tween

func _update_animated_label(value: float, property_name: StringName, label: Label) -> void:
	set(property_name, value)
	_write_label_value(label, value)

func _write_label_value(label: Label, value: float) -> void:
	if label == null:
		return
	label.text = str(int(round(value)))

func _read_label_value(label: Label) -> float:
	if label == null:
		return 0.0
	if not label.text.is_valid_int():
		return 0.0
	return float(label.text.to_int())
