class_name HandUpgradeBalanceConfig
extends Resource

@export_range(1, 12, 1) var options_per_roll: int = 4

@export_group("Reroll Pricing")
@export_range(0, 99, 1) var reroll_base_cost: int = 1
@export_range(0, 99, 1) var reroll_cost_increase_per_use: int = 1

@export_group("Rarity Roll Weights")
@export_range(0.0, 1.0, 0.01) var common_chance: float = 0.6
@export_range(0.0, 1.0, 0.01) var rare_chance: float = 0.3
@export_range(0.0, 1.0, 0.01) var epic_chance: float = 0.1

@export_group("Rarity Bonuses")
@export var common_base_bonus: int = 4
@export var common_mult_bonus: int = 1
@export var rare_base_bonus: int = 9
@export var rare_mult_bonus: int = 2
@export var epic_base_bonus: int = 16
@export var epic_mult_bonus: int = 3

func get_rarity_bonuses() -> Dictionary:
	return {
		HandTypeUpgradeDefinition.UpgradeRarity.COMMON: {
			"base": common_base_bonus,
			"mult": common_mult_bonus,
		},
		HandTypeUpgradeDefinition.UpgradeRarity.RARE: {
			"base": rare_base_bonus,
			"mult": rare_mult_bonus,
		},
		HandTypeUpgradeDefinition.UpgradeRarity.EPIC: {
			"base": epic_base_bonus,
			"mult": epic_mult_bonus,
		},
	}

func get_normalized_rarity_roll_weights() -> Dictionary:
	var common := max(common_chance, 0.0)
	var rare := max(rare_chance, 0.0)
	var epic := max(epic_chance, 0.0)
	var total := common + rare + epic
	if total <= 0.0:
		return {
			HandTypeUpgradeDefinition.UpgradeRarity.COMMON: 0.6,
			HandTypeUpgradeDefinition.UpgradeRarity.RARE: 0.3,
			HandTypeUpgradeDefinition.UpgradeRarity.EPIC: 0.1,
		}
	return {
		HandTypeUpgradeDefinition.UpgradeRarity.COMMON: common / total,
		HandTypeUpgradeDefinition.UpgradeRarity.RARE: rare / total,
		HandTypeUpgradeDefinition.UpgradeRarity.EPIC: epic / total,
	}
