class_name ShopBalanceConfig
extends Resource

@export_range(0, 20, 1) var trinket_option_count: int = 4

@export_group("Reroll Pricing")
@export_range(0, 99, 1) var reroll_base_cost: int = 1
@export_range(0.0, 5.0, 0.01) var round_cost_multiplier_step: float = 0.1
@export_range(0, 20, 1) var reroll_escalation_step: int = 0
@export_range(0.0, 5.0, 0.01) var cost_discount_factor: float = 0.75

@export_group("Rarity Weights")
@export_range(0.0, 999.0, 0.1) var common_weight: float = 70.0
@export_range(0.0, 999.0, 0.1) var uncommon_weight: float = 22.0
@export_range(0.0, 999.0, 0.1) var rare_weight: float = 7.0
@export_range(0.0, 999.0, 0.1) var epic_weight: float = 1.0

func get_rarity_weights() -> Dictionary:
	return {
		TrinketData.TrinketRarity.COMMON: common_weight,
		TrinketData.TrinketRarity.UNCOMMON: uncommon_weight,
		TrinketData.TrinketRarity.RARE: rare_weight,
		TrinketData.TrinketRarity.EPIC: epic_weight,
	}
