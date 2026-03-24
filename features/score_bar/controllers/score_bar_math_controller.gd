extends Node
class_name ScoreBarMathController

const CALCULATION_DELAY_SECONDS := 0.5

@export var main_score: MainScore

var _preview_breakdown: Dictionary = {}
var _show_preview_math: bool = false

func update_preview(breakdown: Dictionary) -> void:
	_preview_breakdown = breakdown.duplicate(true)
	if breakdown.is_empty():
		if main_score != null:
			main_score.reset_math_display()
		return

	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))
	if main_score != null:
		main_score.set_hand_type(hand_name)
	if _show_preview_math:
		_apply_preview_math(base_value, group_total, mult_value, final_score)

func animate_played_hand(tree: SceneTree, breakdown: Dictionary) -> void:
	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))

	_show_preview_math = false
	if main_score != null:
		main_score.set_hand_type(hand_name)
		main_score.zero_math_display()
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	if main_score != null:
		main_score.set_base(base_value)
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	if main_score != null:
		main_score.set_mult(mult_value)
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	if main_score != null:
		main_score.set_base(base_value + group_total)
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout

	if main_score != null:
		main_score.set_result(final_score)

func animate_quota_update(tree: SceneTree, projected_quota: int) -> void:
	if main_score == null:
		return
	await tree.create_timer(CALCULATION_DELAY_SECONDS).timeout
	main_score.set_quota(max(projected_quota, 0))

func reset_display() -> void:
	_preview_breakdown.clear()
	_show_preview_math = false
	if main_score != null:
		main_score.reset_math_display()

func zero_math_display() -> void:
	_show_preview_math = false
	if main_score != null:
		main_score.zero_math_display()

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
	if main_score != null:
		main_score.zero_math_display()

func _apply_preview_math(base_value: int, group_total: int, mult_value: int, final_score: int) -> void:
	if main_score == null:
		return
	main_score.set_base(base_value + group_total)
	main_score.set_mult(mult_value)
	main_score.set_result(final_score)
