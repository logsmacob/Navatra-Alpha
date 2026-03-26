class_name TrinketData
extends Resource

enum TrinketRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
}

enum TriggerType {
	ALWAYS,
	ON_HAND_TYPE,
	ON_FACE_VALUE,
}

# Rarity Colors
const RARITY_COLORS := {
	TrinketRarity.COMMON: Color(0.8, 0.8, 0.8),      # Gray
	TrinketRarity.UNCOMMON: Color(0.2, 0.8, 0.2),    # Green
	TrinketRarity.RARE: Color(0.2, 0.4, 1.0),        # Blue
	TrinketRarity.EPIC: Color(0.7, 0.3, 1.0),        # Purple
}

const GENERAL_MODIFIER_LABELS := {
	"luck": "Luck",
	"base_marbles_per_round": "Base Marbles per Round",
	"shop_rerolls": "Re-Rolls",
	"shop_playable_hands": "Playable Hands",
	"face_1_to": "Face [1]",
	"face_2_to": "Face [2]",
	"face_3_to": "Face [3]",
	"face_4_to": "Face [4]",
	"face_5_to": "Face [5]",
	"face_6_to": "Face [6]",
	"base_1_value": "Face Value [1]",
	"base_2_value": "Face Value [2]",
	"base_3_value": "Face Value [3]",
	"base_4_value": "Face Value [4]",
	"base_5_value": "Face Value [5]",
	"base_6_value": "Face Value [6]",
	"mult_1_value": "Face Value [1]",
	"mult_2_value": "Face Value [2]",
	"mult_3_value": "Face Value [3]",
	"mult_4_value": "Face Value [4]",
	"mult_5_value": "Face Value [5]",
	"mult_6_value": "Face Value [6]",
}

@export_group("Display")
@export var texture: AtlasTexture
@export var id: String = ""
@export var item_name: String = ""

@export_group("Economy")
@export var cost: int = 0
@export_range(0.0, 999.0, 0.1) var weight: float = 1.0
@export var rarity: TrinketRarity = TrinketRarity.COMMON

@export_group("Trigger")
@export var trigger_type: TriggerType = TriggerType.ALWAYS
@export_range(0.0, 100.0, 0.1) var trigger_chance_percent: float = 100.0
@export var hand_type: HandEvaluatorService.HandType = HandEvaluatorService.HandType.HIGH_DIE
@export_range(1, 6, 1) var trigger_face_value: int = 1

@export_group("Scoring")
@export var base: int = 0
@export var mult: int = 0

@export_subgroup("Run Modifiers")
@export var luck: int = 0
@export var base_marbles_per_round: int = 0
@export var shop_rerolls: int = 0
@export var shop_playable_hands: int = 0

@export_subgroup("Face Mapping")
@export var face_1_to: int = 0
@export var face_2_to: int = 0
@export var face_3_to: int = 0
@export var face_4_to: int = 0
@export var face_5_to: int = 0
@export var face_6_to: int = 0

@export_subgroup("Face Base Bonuses")
@export var base_1_value: int = 0
@export var base_2_value: int = 0
@export var base_3_value: int = 0
@export var base_4_value: int = 0
@export var base_5_value: int = 0
@export var base_6_value: int = 0

@export_subgroup("Face Mult Bonuses")
@export var mult_1_value: int = 0
@export var mult_2_value: int = 0
@export var mult_3_value: int = 0
@export var mult_4_value: int = 0
@export var mult_5_value: int = 0
@export var mult_6_value: int = 0

@export_group("Availability")
@export_range(1, 999, 1) var min_round: int = 1
@export_range(1, 999, 1) var max_round: int = 999


# Get rarity color
func get_rarity_color() -> Color:
	return RARITY_COLORS.get(rarity, Color.WHITE)


# Display name
func get_display_name() -> String:
	return item_name if not item_name.is_empty() else id


# Colored name (for RichTextLabel)
func get_colored_name() -> String:
	var color := get_rarity_color().to_html()
	return "[color=%s]%s[/color]" % [color, get_display_name()]


# Modifier dictionary
func get_general_modifier_changes() -> Dictionary:
	return {
		"luck": luck,
		"base_marbles_per_round": base_marbles_per_round,
		"shop_rerolls": shop_rerolls,
		"shop_playable_hands": shop_playable_hands,
		"face_1_to": face_1_to,
		"face_2_to": face_2_to,
		"face_3_to": face_3_to,
		"face_4_to": face_4_to,
		"face_5_to": face_5_to,
		"face_6_to": face_6_to,
		"base_1_value": base_1_value,
		"base_2_value": base_2_value,
		"base_3_value": base_3_value,
		"base_4_value": base_4_value,
		"base_5_value": base_5_value,
		"base_6_value": base_6_value,
		"mult_1_value": mult_1_value,
		"mult_2_value": mult_2_value,
		"mult_3_value": mult_3_value,
		"mult_4_value": mult_4_value,
		"mult_5_value": mult_5_value,
		"mult_6_value": mult_6_value,
	}


# Format + / -
func _format_signed_modifier(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return "%d" % value

func _format_face_modifier(value: int) -> String:
	return "[%d]" % value

func _get_texture():
	return texture

func get_trigger_summary() -> String:
	var chance_text := "%s%%" % str(snappedf(trigger_chance_percent, 0.1))
	match trigger_type:
		TriggerType.ON_HAND_TYPE:
			return "%s on %s" % [chance_text, HandEvaluatorService.HandType.keys()[hand_type]]
		TriggerType.ON_FACE_VALUE:
			return "%s on face [%d]" % [chance_text, trigger_face_value]
		_:
			return "%s once" % chance_text

func is_single_activation_trigger() -> bool:
	return trigger_type == TriggerType.ALWAYS

func can_trigger_for_context(triggered_hand_type: HandEvaluatorService.HandType, rolled_face_value: int, has_already_triggered: bool = false) -> bool:
	if is_single_activation_trigger() and has_already_triggered:
		return false

	match trigger_type:
		TriggerType.ON_HAND_TYPE:
			return triggered_hand_type == hand_type
		TriggerType.ON_FACE_VALUE:
			return rolled_face_value == trigger_face_value
		_:
			return true

func roll_trigger_chance(has_already_triggered: bool = false) -> bool:
	if is_single_activation_trigger() and has_already_triggered:
		return false

	if trigger_chance_percent >= 100.0:
		return true
	if trigger_chance_percent <= 0.0:
		return false
	return randf() <= (trigger_chance_percent / 100.0)


# Description
func get_display_discription() -> String:
	var effects: Array[String] = []
	effects.append("Trigger: %s" % get_trigger_summary())

	for key in get_general_modifier_changes().keys():
		var value := int(get_general_modifier_changes()[key])
		if value == 0:
			continue
		effects.append(_get_modifier_effect_text(key, value))

	if effects.is_empty():
		return "No effect"

	return "\n".join(effects)


func _get_modifier_effect_text(key: String, value: int) -> String:
	var signed_value := _format_signed_modifier(value)

	if key.begins_with("base_") and key.ends_with("_value"):
		return "%s %s Base" % [GENERAL_MODIFIER_LABELS.get(key, key), signed_value]

	if key.begins_with("mult_") and key.ends_with("_value"):
		return "%s %s Mult" % [GENERAL_MODIFIER_LABELS.get(key, key), signed_value]

	if key.begins_with("face_") and key.ends_with("_to"):
		return "%s into %s" % [GENERAL_MODIFIER_LABELS.get(key, key), _format_face_modifier(value)]

	return "%s %s" % [GENERAL_MODIFIER_LABELS.get(key, key), signed_value]


# Availability
func is_available_for_round(round_number: int) -> bool:
	return round_number >= min_round and round_number <= max_round


# Full effect text
func get_effect_text() -> String:
	return "%s | Cost %d | %s" % [
		get_display_name(),
		cost,
		get_display_discription(),
	]
