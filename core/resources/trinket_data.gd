class_name TrinketData
extends Resource

enum TrinketRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
}

# Rarity Colors
const RARITY_COLORS := {
	TrinketRarity.COMMON: Color(0.8, 0.8, 0.8),      # Gray
	TrinketRarity.UNCOMMON: Color(0.2, 0.8, 0.2),    # Green
	TrinketRarity.RARE: Color(0.2, 0.4, 1.0),        # Blue
	TrinketRarity.EPIC: Color(0.7, 0.3, 1.0),        # Purple
}

@export_group("Display")
@export var texture: AtlasTexture
@export var id: String = ""
@export var item_name: String = ""

@export_group("Economy")
@export var cost: int = 0
@export_range(0.0, 999.0, 0.1) var weight: float = 1.0
@export var rarity: TrinketRarity = TrinketRarity.COMMON

@export_group("Scoring")
@export var base: int = 0
@export var mult: int = 0

@export_subgroup("Run Modifiers")
@export var luck: int = 0
@export var base_marbles_per_round: int = 0
@export var shop_rerolls: int = 0
@export var shop_playable_hands: int = 0

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

func get_runtime_scoring_bonus(_play_context: Dictionary) -> Dictionary:
	return {
		"base": base,
		"mult": mult,
		"currency": 0,
	}

func apply_purchase_effects(game_state: Node) -> void:
	# Child classes can override this for one-time side-effects.
	# Example: converting a specific die to a custom material.
	if game_state == null:
		return


# Format + / -
func _format_signed_modifier(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return "%d" % value

func _get_texture():
	return texture


# Description
func get_display_description() -> String:
	var effects: Array[String] = []
	if base != 0:
		effects.append("Triggered Base %+d" % base)
	if mult != 0:
		effects.append("Triggered Mult %+d" % mult)

	var modifiers := get_general_modifier_changes()
	for key in ModifierSchema.get_general_modifier_keys():
		var value := int(modifiers.get(key, 0))
		if value == 0:
			continue
		effects.append(_get_modifier_effect_text(key, value))

	if effects.is_empty():
		return "No effect"

	return "\n".join(effects)

# Backward-compatible alias for older callers and scenes.
func get_display_discription() -> String:
	return get_display_description()


func _get_modifier_effect_text(key: String, value: int) -> String:
	var signed_value := _format_signed_modifier(value)

	if key.begins_with("base_") and key.ends_with("_value"):
		return "%s %s Base" % [ModifierSchema.GENERAL_MODIFIER_LABELS.get(key, key), signed_value]

	if key.begins_with("mult_") and key.ends_with("_value"):
		return "%s %s Mult" % [ModifierSchema.GENERAL_MODIFIER_LABELS.get(key, key), signed_value]

	return "%s %s" % [ModifierSchema.GENERAL_MODIFIER_LABELS.get(key, key), signed_value]


# Availability
func is_available_for_round(round_number: int) -> bool:
	return round_number >= min_round and round_number <= max_round


# Full effect text
func get_effect_text() -> String:
	return "%s | Cost %d | %s" % [
		get_display_name(),
		cost,
		get_display_description(),
	]
