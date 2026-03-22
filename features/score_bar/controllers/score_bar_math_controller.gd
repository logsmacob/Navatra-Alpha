extends Node
class_name ScoreBarMathController

const CALCULATION_DELAY_SECONDS := 0.5

@export var hand_type_label: Label
@export var base_label: Label
@export var mult_label: Label
@export var result_label: Label

var _preview_breakdown: Dictionary = {}
var _show_preview_math: bool = false

func update_preview(breakdown: Dictionary) -> void:
	_preview_breakdown = breakdown.duplicate(true)
	if breakdown.is_empty():
		hand_type_label.text = "Hand Type:"
		_zero_math_display()
		return

	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))
	hand_type_label.text = "%s:" % hand_name
	if _show_preview_math:
		_apply_preview_math(base_value, group_total, mult_value, final_score)

func animate_played_hand(tree: SceneTree, breakdown: Dictionary) -> void:
	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))

	_show_preview_math = false
	hand_type_label.text = "%s:" % hand_name
	_zero_math_display()
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	base_label.text = "%d" % base_value
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	mult_label.text = "%d" % mult_value
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	base_label.text = "%d" % (base_value + group_total)
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	result_label.text = "%d" % final_score

func reset_display() -> void:
	_preview_breakdown.clear()
	_show_preview_math = false
	_zero_math_display()
	hand_type_label.text = "Hand Type:"

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
	base_label.text = "%d" % 0
	mult_label.text = "%d" % 0
	result_label.text = "%d" % 0

func _apply_preview_math(base_value: int, group_total: int, mult_value: int, final_score: int) -> void:
	base_label.text = "%d" % (base_value + group_total)
	mult_label.text = "%d" % mult_value
	result_label.text = "%d" % final_score
