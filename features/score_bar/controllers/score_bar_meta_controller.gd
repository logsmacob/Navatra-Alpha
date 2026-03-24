extends Node
class_name ScoreBarMetaController

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
	{"key": "mult_1_value", "label": "Mult 1 Value"},
	{"key": "mult_2_value", "label": "Mult 2 Value"},
	{"key": "mult_3_value", "label": "Mult 3 Value"},
	{"key": "mult_4_value", "label": "Mult 4 Value"},
	{"key": "mult_5_value", "label": "Mult 5 Value"},
	{"key": "mult_6_value", "label": "Mult 6 Value"},
]

@export var corner_label: CornerLabel
@export var main_score: MainScore
@export var general_modifiers_label_path: Label

func update_state(state: Dictionary, general_modifiers: Dictionary) -> void:
	if corner_label != null:
		corner_label.set_round(int(state.get("round_index", 0)), GameState.MAX_ROUNDS)
		corner_label.set_marbles(int(state.get("currency", 0)))
	if main_score != null:
		main_score.set_quota(int(state.get("quota_remaining", 0)))
	_set_label_text(_get_general_modifiers_label(), _build_general_modifier_text(general_modifiers))

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = ["General Modifiers:"]
	for row in GENERAL_MODIFIER_ROWS:
		lines.append("- %s: %d" % [str(row.label), int(modifiers.get(row.key, 0))])
	return "\n".join(lines)

func _get_general_modifiers_label() -> Label:
	return general_modifiers_label_path

func _set_label_text(label: Label, value: String) -> void:
	if label != null:
		label.text = value
