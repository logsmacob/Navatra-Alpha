extends Control
class_name StatsScreen

const GENERAL_MODIFIER_ROWS := ModifierSchema.GENERAL_MODIFIER_ROWS
const FACE_VALUES := [1, 2, 3, 4, 5, 6]
const HAND_TYPE_ROWS := [
	{"type": HandEvaluatorService.HandType.HIGH_DIE, "label": "High Die", "recipe": "Highest single die only"},
	{"type": HandEvaluatorService.HandType.ONE_PAIR, "label": "One Pair", "recipe": "Two dice with the same value"},
	{"type": HandEvaluatorService.HandType.TWO_PAIR, "label": "Two Pair", "recipe": "Two different pairs"},
	{"type": HandEvaluatorService.HandType.THREE_OF_A_KIND, "label": "Three of a Kind", "recipe": "Three dice with the same value"},
	{"type": HandEvaluatorService.HandType.STRAIGHT, "label": "Straight", "recipe": "1-2-3-4-5 or 2-3-4-5-6"},
	{"type": HandEvaluatorService.HandType.FULL_HOUSE, "label": "Full House", "recipe": "Three of a kind + one pair"},
	{"type": HandEvaluatorService.HandType.FOUR_OF_A_KIND, "label": "Four of a Kind", "recipe": "Four dice with the same value"},
	{"type": HandEvaluatorService.HandType.FIVE_OF_A_KIND, "label": "Five of a Kind", "recipe": "All five dice the same"},
]

@export var general_modifiers_label: Label
@export var hand_types_label: Label
@export var face_label: Label

var _score_rules := HandScoreRulesService.new()

func _ready() -> void:
	if general_modifiers_label == null:
		general_modifiers_label = get_node_or_null("GeneralModifiers")
	if not GameState.general_modifiers_changed.is_connected(_on_general_modifiers_changed):
		GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)
	_on_general_modifiers_changed(GameState.get_general_modifiers())

func update_general_modifiers(modifiers: Dictionary) -> void:
	if general_modifiers_label == null:
		return
	general_modifiers_label.text = _build_general_modifier_text(modifiers)

func _on_general_modifiers_changed(modifiers: Dictionary) -> void:
	update_general_modifiers(modifiers)

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = ["Stats"]
	lines.append("")
	lines.append("Face Values")
	for face_value in FACE_VALUES:
		var base_value := int(modifiers.get("base_%d_value" % face_value, face_value))
		var mult_value := int(modifiers.get("mult_%d_value" % face_value, 0))
		lines.append("- Face %d: Base %d | Mult %s" % [face_value, base_value, _format_signed_modifier(mult_value)])
	lines.append("")
	lines.append("General Modifiers")
	for row in GENERAL_MODIFIER_ROWS:
		if str(row.key).begins_with("base_") or str(row.key).begins_with("mult_"):
			continue
		var value := int(modifiers.get(row.key, 0))
		lines.append("- %s" % _format_general_modifier_line(str(row.key), str(row.label), value))
	lines.append("")
	lines.append("Hand Types")
	for row in HAND_TYPE_ROWS:
		var hand_type := int(row.type)
		var values := _score_rules.get_scoring_values(hand_type)
		var base_value := int(values.get("base", 0))
		var mult_value := int(values.get("mult", 0))
		lines.append(
			"- %s: Base %d | Mult %d | Recipe: %s"
			% [str(row.label), base_value, mult_value, str(row.recipe)]
		)
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
