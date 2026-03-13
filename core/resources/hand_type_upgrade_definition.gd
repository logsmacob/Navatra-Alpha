class_name HandTypeUpgradeDefinition
extends Resource

enum UpgradeRarity {
	COMMON,
	RARE,
	EPIC,
}

@export var id: String = ""
@export var hand_type: int = 0
@export var hand_type_name: String = ""
@export var rarity: UpgradeRarity = UpgradeRarity.COMMON
@export var base_bonus: int = 0
@export var mult_bonus: int = 0

func get_title() -> String:
	return "%s (%s)" % [hand_type_name, UpgradeRarity.keys()[rarity].capitalize()]

func get_description() -> String:
	return "+%d Base | +%d Mult" % [base_bonus, mult_bonus]
