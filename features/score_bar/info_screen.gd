extends Control
class_name StatsScreen

const GENERAL_MODIFIER_ROWS := ModifierSchema.GENERAL_MODIFIER_ROWS
const FACE_VALUES := [1, 2, 3, 4, 5, 6]
const TITLE_SIZE := 26
const BODY_SIZE := 18
const SUBTEXT_SIZE := 14
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

@export var general_modifiers_label: RichTextLabel
@export var hand_types_label: RichTextLabel
@export var face_label: RichTextLabel

var _score_rules := HandScoreRulesService.new()

func _ready() -> void:
	if general_modifiers_label == null:
		general_modifiers_label = get_node_or_null("GeneralModifiers")
	if hand_types_label == null:
		hand_types_label = get_node_or_null("HandType")
	if face_label == null:
		face_label = get_node_or_null("Face")
	if not GameState.general_modifiers_changed.is_connected(_on_general_modifiers_changed):
		GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)
	if not GameState.hand_type_upgrades_changed.is_connected(_on_hand_type_upgrades_changed):
		GameState.hand_type_upgrades_changed.connect(_on_hand_type_upgrades_changed)
	_on_general_modifiers_changed(GameState.get_general_modifiers())

func update_general_modifiers(modifiers: Dictionary) -> void:
	if general_modifiers_label != null:
		general_modifiers_label.text = _build_general_modifier_text(modifiers)
	if face_label != null:
		face_label.text = _build_face_values_text(modifiers)
	if hand_types_label != null:
		hand_types_label.text = _build_hand_types_text()

func _on_general_modifiers_changed(modifiers: Dictionary) -> void:
	update_general_modifiers(modifiers)

func _on_hand_type_upgrades_changed(_upgrades: Dictionary) -> void:
	if hand_types_label != null:
		hand_types_label.text = _build_hand_types_text()

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = [_format_title_bbcode("General Modifiers")]
	for row in GENERAL_MODIFIER_ROWS:
		if str(row.key).begins_with("base_") or str(row.key).begins_with("mult_"):
			continue
		var value := int(modifiers.get(row.key, 0))
		lines.append(_format_body_bbcode("• %s" % _format_general_modifier_line(str(row.key), str(row.label), value)))
	return "\n".join(lines)

func _build_face_values_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = [_format_title_bbcode("Face Values")]
	for face_value in FACE_VALUES:
		var base_value := int(modifiers.get("base_%d_value" % face_value, face_value))
		var mult_value := int(modifiers.get("mult_%d_value" % face_value, 0))
		lines.append(
			"%s\n%s"
			% [
				_format_body_bbcode("• [b]Face %d[/b]" % face_value),
				_format_subtext_bbcode("%s  %s" % [_format_base_bbcode(base_value), _format_mult_bbcode(_format_signed_modifier(mult_value))]),
			]
		)
	return "\n".join(lines)

func _build_hand_types_text() -> String:
	var lines: Array[String] = [_format_title_bbcode("Hand Types")]
	var scoring_context := HandScoringContext.new(GameState.hand_type_upgrades, GameState.round_score_multiplier)
	for row in HAND_TYPE_ROWS:
		var hand_type := int(row.type)
		var values := _score_rules.get_scoring_values(hand_type, scoring_context)
		var base_value := int(values.get("base", 0))
		var mult_value := int(values.get("mult", 0))
		lines.append(
			"%s\n%s\n%s"
			% [
				_format_body_bbcode("• [b]%s[/b]" % str(row.label)),
				_format_subtext_bbcode(str(row.recipe)),
				_format_subtext_bbcode("%s  %s" % [_format_base_bbcode(base_value), _format_mult_bbcode(str(mult_value))]),
			]
		)
	return "\n".join(lines)

func _format_title_bbcode(text: String) -> String:
	return "[b][font_size=%d]%s[/font_size][/b]" % [TITLE_SIZE, text]

func _format_body_bbcode(text: String) -> String:
	return "[font_size=%d]%s[/font_size]" % [BODY_SIZE, text]

func _format_subtext_bbcode(text: String) -> String:
	return "[font_size=%d]%s[/font_size]" % [SUBTEXT_SIZE, text]


func _format_base_bbcode(value: Variant) -> String:
	return "[b][color=#62A8FF]Base %s[/color][/b]" % str(value)

func _format_mult_bbcode(value: Variant) -> String:
	return "[b][color=#FF7AD9]Mult %s[/color][/b]" % str(value)

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
