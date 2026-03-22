extends Control
## Score bar script: coordinates this part of the game's behavior.
class_name ScoreBar

const GENERAL_MODIFIER_ROWS := [
	{"key": "luck", "label": "Luck"},
	{"key": "base_marbles_per_round", "label": "Base Marbles per Round"},
	{"key": "shop_rerolls", "label": "Re-Rolls"},
	{"key": "shop_playable_hands", "label": "Playable Hands"},
	{"key": "base_1_value", "label": "Base 1 Value"},
	{"key": "base_2_value", "label": "Base 2 Value"},
	{"key": "base_3_value", "label": "Base 3 Value"},
	{"key": "base_4_value", "label": "Base 4 Value"},
	{"key": "base_5_value", "label": "Base 5 Value"},
	{"key": "base_6_value", "label": "Base 6 Value"},
]

const CALCULATION_DELAY_SECONDS := 0.5

@export var round_index_label: Label
@export var marble_label: Label
@export var current_hand_points_label: Label
@export var hand_type_label: Label
@export var current_hand_points_label_math: Label
@export var general_modifiers_label: Label
@export var Base: Label
@export var Mult: Label
@export var Result: Label
@export var Quota: Label

var score_manager: ScoreManager
var _preview_breakdown: Dictionary = {}
var _show_preview_math: bool = false

func _ready() -> void:
	score_manager = ScoreManager.new()
	add_child(score_manager)
	GameState.round_started.connect(_on_round_started)
	GameState.round_state_changed.connect(_on_round_state_changed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)
	_reset_score_display()
	_update_meta_labels(GameState.get_round_state())

func set_scoring_context(context: HandScoringContext) -> void:
	if score_manager == null:
		return
	score_manager.set_scoring_context(context)

func preview_hand(hand_data: DiceHand) -> void:
	if hand_data == null or score_manager == null:
		return

	set_scoring_context(_build_scoring_context())
	score_manager.preview_hand(hand_data.to_array())
	_update_preview_labels(score_manager.get_last_breakdown())

func can_play_previewed_hand() -> bool:
	return score_manager != null and score_manager.can_play_hand()

func play_previewed_hand() -> Dictionary:
	if score_manager == null or not score_manager.can_play_hand():
		return {
			"played": false,
			"hand_name": "Unknown",
			"applied_score": 0,
		}

	var breakdown := score_manager.get_last_breakdown()
	await _animate_played_hand(breakdown)

	score_manager.play_hand()
	var played_hand_name := str(breakdown.get("hand_name", "Unknown"))
	var applied_score := score_manager.commit_played_hand()

	return {
		"played": true,
		"hand_name": played_hand_name,
		"applied_score": applied_score,
	}

func update_state(state: Dictionary = {}) -> void:
	if state.is_empty():
		state = GameState.get_round_state()

	_update_meta_labels(state)
	general_modifiers_label.text = _build_general_modifier_text(GameState.get_general_modifiers())

func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	_update_meta_labels({
		"round_index": round_index,
		"quota_remaining": quota,
		"hands_remaining": hands,
		"rerolls_remaining": rerolls,
		"currency": GameState.currency,
	})
	_reset_score_display()

func _on_round_state_changed(state: Dictionary) -> void:
	update_state(state)

func _on_currency_changed(_amount: int) -> void:
	update_state()

func _on_general_modifiers_changed(_modifiers: Dictionary) -> void:
	update_state()

func _update_meta_labels(state: Dictionary) -> void:
	round_index_label.text = "Round %d/%d" % [int(state.get("round_index", 0)), GameState.MAX_ROUNDS]
	Quota.text = "%d" % int(state.get("quota_remaining", 0))
	marble_label.text = "Marbles: %d" % int(state.get("currency", 0))

func _update_preview_labels(breakdown: Dictionary) -> void:
	_preview_breakdown = breakdown.duplicate(true)
	if breakdown.is_empty():
		_reset_score_display()
		return

	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))
	current_hand_points_label.text = "Current Hand Points: %d" % final_score
	hand_type_label.text = "%s:" % hand_name
	if _show_preview_math:
		_apply_preview_math(base_value, group_total, mult_value, final_score)
	else:
		_clear_math_values()

func _animate_played_hand(breakdown: Dictionary) -> void:
	var hand_name := str(breakdown.get("hand_name", "-"))
	var base_value := int(breakdown.get("base", 0))
	var group_total := int(breakdown.get("group_total", 0))
	var mult_value := int(breakdown.get("mult", 0))
	var final_score := int(breakdown.get("final_score", 0))

	hand_type_label.text = "%s:" % hand_name
	Base.text = "%d" % 0
	Mult.text = "%d" % 0
	Result.text = "%d" % 0
	current_hand_points_label.text = "Current Hand Points: 0"
	current_hand_points_label_math.text = "(Base 0 + Dice 0) x Mult 0 = 0"

	Base.text = "%d" % base_value
	current_hand_points_label_math.text = "Base = %d" % base_value
	await get_tree().create_timer(CALCULATION_DELAY_SECONDS).timeout

	Mult.text = "%d" % mult_value
	current_hand_points_label_math.text = "Base %d | Mult = %d" % [base_value, mult_value]
	await get_tree().create_timer(CALCULATION_DELAY_SECONDS).timeout

	Base.text = "%d" % (base_value + group_total)
	current_hand_points_label_math.text = "Base %d + Dice %d = %d" % [base_value, group_total, base_value + group_total]
	await get_tree().create_timer(CALCULATION_DELAY_SECONDS).timeout

	Result.text = "%d" % final_score
	current_hand_points_label.text = "Current Hand Points: %d" % final_score
	current_hand_points_label_math.text = "(%d) x %d = %d" % [base_value + group_total, mult_value, final_score]
	_clear_preview_math()

func _reset_score_display() -> void:
	_preview_breakdown.clear()
	_show_preview_math = false
	_clear_math_values()
	hand_type_label.text = "Hand Type:"
	current_hand_points_label.text = "Current Hand Points: 0"

func clear_after_play_reset() -> void:
	_show_preview_math = false
	_clear_math_values()
	hand_type_label.text = "Hand Type:"
	current_hand_points_label.text = "Current Hand Points: 0"
	current_hand_points_label_math.text = "(Base 0 + Dice 0) x Mult 0 = 0"

func show_preview_math() -> void:
	_show_preview_math = true
	if _preview_breakdown.is_empty():
		_clear_math_values()
		return
	_apply_preview_math(
		int(_preview_breakdown.get("base", 0)),
		int(_preview_breakdown.get("group_total", 0)),
		int(_preview_breakdown.get("mult", 0)),
		int(_preview_breakdown.get("final_score", 0))
	)

func hide_preview_math() -> void:
	_show_preview_math = false
	_clear_preview_math()

func _apply_preview_math(base_value: int, group_total: int, mult_value: int, final_score: int) -> void:
	Base.text = "%d" % (base_value + group_total)
	Mult.text = "%d" % mult_value
	Result.text = "%d" % final_score
	current_hand_points_label_math.text = "(Base %d + Dice %d) x Mult %d = %d" % [base_value, group_total, mult_value, final_score]

func _clear_preview_math() -> void:
	_clear_math_values()
	current_hand_points_label_math.text = "(Base 0 + Dice 0) x Mult 0 = 0"

func _clear_math_values() -> void:
	Base.text = "%d" % 0
	Mult.text = "%d" % 0
	Result.text = "%d" % 0

func _build_scoring_context() -> HandScoringContext:
	return HandScoringContext.new(GameState.hand_type_upgrades, GameState.round_score_multiplier)

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = ["General Modifiers:"]
	for row in GENERAL_MODIFIER_ROWS:
		lines.append("- %s: %d" % [str(row.label), int(modifiers.get(row.key, 0))])
	return "\n".join(lines)
