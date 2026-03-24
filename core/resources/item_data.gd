class_name ItemData

extends Resource

enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
}

const GENERAL_MODIFIER_LABELS := {
	"luck": "Luck",
	"base_marbles_per_round": "Base Marbles per Round",
	"shop_rerolls": "Re-Rolls",
	"shop_playable_hands": "Playable Hands",
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

@export var id: String = ""
@export var item_name: String = ""
@export var cost: int = 0

@export var hand_type: HandEvaluatorService.HandType = HandEvaluatorService.HandType.HIGH_DIE

@export var base: int = 0
@export var mult: int = 0

@export var luck: int = 0
@export var base_marbles_per_round: int = 0
@export var shop_rerolls: int = 0
@export var shop_playable_hands: int = 0
@export var base_1_value: int = 0
@export var base_2_value: int = 0
@export var base_3_value: int = 0
@export var base_4_value: int = 0
@export var base_5_value: int = 0
@export var base_6_value: int = 0
@export var mult_1_value: int = 0
@export var mult_2_value: int = 0
@export var mult_3_value: int = 0
@export var mult_4_value: int = 0
@export var mult_5_value: int = 0
@export var mult_6_value: int = 0

@export_range(0.0, 999.0, 0.1) var weight: float = 1.0
@export var rarity: ItemRarity = ItemRarity.COMMON
@export_range(1, 999, 1) var min_round: int = 1
@export_range(1, 999, 1) var max_round: int = 999

func get_display_name() -> String:
	return item_name if not item_name.is_empty() else id

func get_general_modifier_changes() -> Dictionary:
	return {
		"luck": luck,
		"base_marbles_per_round": base_marbles_per_round,
		"shop_rerolls": shop_rerolls,
		"shop_playable_hands": shop_playable_hands,
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

func _format_signed_modifier(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return "%d" % value

func get_display_discription() -> String:
	var effects: Array[String] = []
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
	return "%s %s" % [GENERAL_MODIFIER_LABELS.get(key, key), signed_value]

func is_available_for_round(round_number: int) -> bool:
	return round_number >= min_round and round_number <= max_round

func get_effect_text() -> String:
	return "%s | Cost %d | %s" % [
		get_display_name(),
		cost,
		get_display_discription(),
	]
