extends Node
class_name ScoreBarMathController

const CALCULATION_DELAY_SECONDS := 0.5

@export_node_path("Label") var hand_type_label_path: NodePath
@export_node_path("Label") var base_label_path: NodePath
@export_node_path("Label") var mult_label_path: NodePath
@export_node_path("Label") var result_label_path: NodePath

var _preview_breakdown: Dictionary = {}
var _show_preview_math: bool = false

func update_preview(breakdown: Dictionary) -> void:
	_preview_breakdown = breakdown.duplicate(true)
	if breakdown.is_empty():
		_set_label_text(_get_hand_type_label(), "Hand Type:")
		_zero_math_display()
		return

	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))
	_set_label_text(_get_hand_type_label(), "%s:" % hand_name)
	if _show_preview_math:
		_apply_preview_math(base_value, group_total, mult_value, final_score)

func animate_played_hand(tree: SceneTree, breakdown: Dictionary) -> void:
	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))

	_show_preview_math = false
	_set_label_text(_get_hand_type_label(), "%s:" % hand_name)
	_zero_math_display()
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	_set_label_text(_get_base_label(), "%d" % base_value)
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	_set_label_text(_get_mult_label(), "%d" % mult_value)
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	_set_label_text(_get_base_label(), "%d" % (base_value + group_total))
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	_set_label_text(_get_result_label(), "%d" % final_score)

func reset_display() -> void:
	_preview_breakdown.clear()
	_show_preview_math = false
	_zero_math_display()
	_set_label_text(_get_hand_type_label(), "Hand Type:")

func zero_math_display() -> void:
	_show_preview_math = false
	_zero_math_display()

func clear_after_play_reset() -> void:
	_show_preview_math = false
	if _preview_breakdown.is_empty():
		return
	update_preview(_preview_breakdown)

func show_preview_math() -> void:
	_show_preview_math = true
	if _preview_breakdown.is_empty():
		return
	_apply_preview_math(
		int(_preview_breakdown.get("base", 0)),
		int(_preview_breakdown.get("group_total", 0)),
		int(_preview_breakdown.get("mult", 0)),
		int(_preview_breakdown.get("final_score", 0))
	)

func hide_preview_math() -> void:
	_show_preview_math = false
	_zero_math_display()

func _zero_math_display() -> void:
	_set_label_text(_get_base_label(), "%d" % 0)
	_set_label_text(_get_mult_label(), "%d" % 0)
	_set_label_text(_get_result_label(), "%d" % 0)

func _apply_preview_math(base_value: int, group_total: int, mult_value: int, final_score: int) -> void:
	_set_label_text(_get_base_label(), "%d" % (base_value + group_total))
	_set_label_text(_get_mult_label(), "%d" % mult_value)
	_set_label_text(_get_result_label(), "%d" % final_score)

func _get_hand_type_label() -> Label:
	return get_node_or_null(hand_type_label_path) as Label

func _get_base_label() -> Label:
	return get_node_or_null(base_label_path) as Label

func _get_mult_label() -> Label:
	return get_node_or_null(mult_label_path) as Label

func _get_result_label() -> Label:
	return get_node_or_null(result_label_path) as Label

func _set_label_text(label: Label, value: String) -> void:
	if label != null:
		label.text = value
