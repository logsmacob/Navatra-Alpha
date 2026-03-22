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
]

@export var round_index_label: Label
@export var marble_label: Label
@export var quota_label: Label
@export var general_modifiers_label: Label

func update_state(state: Dictionary, general_modifiers: Dictionary) -> void:
	if round_index_label != null:
		round_index_label.text = "Round %d/%d" % [int(state.get("round_index", 0)), GameState.MAX_ROUNDS]
	if quota_label != null:
		quota_label.text = "%d" % int(state.get("quota_remaining", 0))
	if marble_label != null:
		marble_label.text = "Marbles: %d" % int(state.get("currency", 0))
	if general_modifiers_label != null:
		general_modifiers_label.text = _build_general_modifier_text(general_modifiers)

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = ["General Modifiers:"]
	for row in GENERAL_MODIFIER_ROWS:
		lines.append("- %s: %d" % [str(row.label), int(modifiers.get(row.key, 0))])
	return "\n".join(lines)
