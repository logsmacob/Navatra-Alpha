class_name ItemData

extends Resource

enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
}

@export var id: String = ""
@export var item_name: String = ""
@export var cost: int = 0

@export var hand_type: int = 0
@export var tag: String = "general"

@export var base: int = 0
@export var mult: int = 0

@export var synergy_base: int = 0
@export var synergy_mult: int = 0

@export_range(0.0, 999.0, 0.1) var weight: float = 1.0
@export var rarity: ItemRarity = ItemRarity.COMMON
@export_range(1, 999, 1) var min_round: int = 1
@export_range(1, 999, 1) var max_round: int = 999

func get_display_name() -> String:
	return item_name if not item_name.is_empty() else id

func is_available_for_round(round_number: int) -> bool:
	return round_number >= min_round and round_number <= max_round

func get_effect_text() -> String:
	return "%s | %s | Cost %d | +%d base +%d mult | synergy +%d/%d" % [
		get_display_name(),
		tag,
		cost,
		base,
		mult,
		synergy_base,
		synergy_mult,
	]
