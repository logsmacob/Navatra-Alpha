extends Node
class_name ScoreBarMetaController

const GENERAL_MODIFIER_ROWS := [
	{"key": "luck", "label": "Luck"},
	{"key": "base_marbles_per_round", "label": "Base Marbles per Round"},
	{"key": "shop_rerolls", "label": "Re-Rolls"},
	{"key": "shop_playable_hands", "label": "Playable Hands"},
	{"key": "face_1_to", "label": "Face [1] Result"},
	{"key": "face_2_to", "label": "Face [2] Result"},
	{"key": "face_3_to", "label": "Face [3] Result"},
	{"key": "face_4_to", "label": "Face [4] Result"},
	{"key": "face_5_to", "label": "Face [5] Result"},
	{"key": "face_6_to", "label": "Face [6] Result"},
	{"key": "base_1_value", "label": "Face Value [1]"},
	{"key": "base_2_value", "label": "Face Value [2]"},
	{"key": "base_3_value", "label": "Face Value [3]"},
	{"key": "base_4_value", "label": "Face Value [4]"},
	{"key": "base_5_value", "label": "Face Value [5]"},
	{"key": "base_6_value", "label": "Face Value [6]"},
	{"key": "mult_1_value", "label": "Face Value [1]"},
	{"key": "mult_2_value", "label": "Face Value [2]"},
	{"key": "mult_3_value", "label": "Face Value [3]"},
	{"key": "mult_4_value", "label": "Face Value [4]"},
	{"key": "mult_5_value", "label": "Face Value [5]"},
	{"key": "mult_6_value", "label": "Face Value [6]"},
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
		var value := int(modifiers.get(row.key, 0))
		lines.append("- %s" % _format_general_modifier_line(str(row.key), str(row.label), value))
	return "\n".join(lines)

func _format_signed_modifier(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return "%d" % value

func _format_general_modifier_line(key: String, label: String, value: int) -> String:
	var signed_value := _format_signed_modifier(value)
	if key.begins_with("base_") and key.ends_with("_value"):
		return "%s %s Base" % [label, signed_value]
	if key.begins_with("mult_") and key.ends_with("_value"):
		return "%s %s Mult" % [label, signed_value]
	return "%s %s" % [label, signed_value]

func _get_general_modifiers_label() -> Label:
	return general_modifiers_label_path

func _set_label_text(label: Label, value: String) -> void:
	if label != null:
		label.text = value
