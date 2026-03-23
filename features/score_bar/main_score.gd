extends PanelContainer
class_name MainScore

const DEFAULT_HAND_TYPE_TITLE := "Hand Type:"
const DEFAULT_HAND_TYPE_VALUE := "-"
const BASE_HIGHLIGHT_COLOR := Color(0, 0.63333344, 1, 1)
const MULT_HIGHLIGHT_COLOR := Color(1, 0, 0.916667, 1)
const DEFAULT_TEXT_COLOR := Color(1, 1, 1, 0.49019608)

@export var _quota_label: Label
@export var _hand_type_label: Label
@export var _hand_type_value_label: Label
@export var _base_label: Label
@export var _mult_label: Label
@export var _result_label: Label

func set_quota(value: int) -> void:
	_quota_label.text = str(value)

func set_hand_type(value: String) -> void:
	_hand_type_value_label.text = value

func set_hand_type_highlight_default() -> void:
	_set_hand_type_color(DEFAULT_TEXT_COLOR)

func set_hand_type_highlight_base() -> void:
	_set_hand_type_color(BASE_HIGHLIGHT_COLOR)

func set_hand_type_highlight_mult() -> void:
	_set_hand_type_color(MULT_HIGHLIGHT_COLOR)

func set_base(value: int) -> void:
	_base_label.text = str(value)

func set_mult(value: int) -> void:
	_mult_label.text = str(value)

func set_result(value: int) -> void:
	_result_label.text = str(value)

func reset_math_display() -> void:
	_hand_type_label.text = DEFAULT_HAND_TYPE_TITLE
	set_hand_type(DEFAULT_HAND_TYPE_VALUE)
	zero_math_display()

func zero_math_display() -> void:
	set_hand_type_highlight_default()
	set_base(0)
	set_mult(0)
	set_result(0)

func _set_hand_type_color(color: Color) -> void:
	_hand_type_label.modulate = color
	_hand_type_value_label.modulate = color
