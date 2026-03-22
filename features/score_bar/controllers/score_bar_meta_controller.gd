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

@export_node_path("Label") var round_index_label_path: NodePath
@export_node_path("Label") var marble_label_path: NodePath
@export_node_path("Label") var quota_label_path: NodePath
@export_node_path("Label") var general_modifiers_label_path: NodePath

func update_state(state: Dictionary, general_modifiers: Dictionary) -> void:
	_set_label_text(_get_round_index_label(), "Round %d/%d" % [int(state.get("round_index", 0)), GameState.MAX_ROUNDS])
	_set_label_text(_get_quota_label(), "%d" % int(state.get("quota_remaining", 0)))
	_set_label_text(_get_marble_label(), "Marbles: %d" % int(state.get("currency", 0)))
	_set_label_text(_get_general_modifiers_label(), _build_general_modifier_text(general_modifiers))

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = ["General Modifiers:"]
	for row in GENERAL_MODIFIER_ROWS:
		lines.append("- %s: %d" % [str(row.label), int(modifiers.get(row.key, 0))])
	return "\n".join(lines)

func _get_round_index_label() -> Label:
	return get_node_or_null(round_index_label_path) as Label

func _get_marble_label() -> Label:
	return get_node_or_null(marble_label_path) as Label

func _get_quota_label() -> Label:
	return get_node_or_null(quota_label_path) as Label

func _get_general_modifiers_label() -> Label:
	return get_node_or_null(general_modifiers_label_path) as Label

func _set_label_text(label: Label, value: String) -> void:
	if label != null:
		label.text = value
