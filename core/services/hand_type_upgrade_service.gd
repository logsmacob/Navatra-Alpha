extends RefCounted

## Hand type upgrade service script: coordinates this part of the game's behavior.
class_name HandTypeUpgradeService

const RARITY_BONUSES := {
	HandTypeUpgradeDefinition.UpgradeRarity.COMMON: {"base": 4, "mult": 1},
	HandTypeUpgradeDefinition.UpgradeRarity.RARE: {"base": 9, "mult": 2},
	HandTypeUpgradeDefinition.UpgradeRarity.EPIC: {"base": 16, "mult": 3},
}

func generate_upgrades(count: int) -> Array[HandTypeUpgradeDefinition]:
	if count <= 0:
		return []

	var hand_types: Array[int] = []
	for hand_type in HandEvaluatorService.HandType.values():
		hand_types.append(hand_type)
	hand_types.shuffle()

	var pick_count: int = mini(count, hand_types.size())
	var results: Array[HandTypeUpgradeDefinition] = []

	for i in pick_count:
		var hand_type: int = hand_types[i]
		var rarity := _roll_rarity()
		results.append(_create_upgrade(hand_type, rarity))

	return results

func apply_upgrade(upgrade: HandTypeUpgradeDefinition, game_state: Node) -> void:
	if upgrade == null or game_state == null:
		return

	if game_state.has_method("add_hand_type_upgrade"):
		game_state.call("add_hand_type_upgrade", upgrade.hand_type, upgrade.base_bonus, upgrade.mult_bonus)

func _create_upgrade(hand_type: int, rarity: HandTypeUpgradeDefinition.UpgradeRarity) -> HandTypeUpgradeDefinition:
	var bonus: Dictionary = RARITY_BONUSES[rarity]
	var upgrade := HandTypeUpgradeDefinition.new()
	upgrade.id = "%s_%s" % [HandEvaluatorService.HandType.keys()[hand_type].to_lower(), HandTypeUpgradeDefinition.UpgradeRarity.keys()[rarity].to_lower()]
	upgrade.hand_type = hand_type
	upgrade.hand_type_name = _hand_type_label(hand_type)
	upgrade.rarity = rarity
	upgrade.base_bonus = int(bonus.get("base", 0))
	upgrade.mult_bonus = int(bonus.get("mult", 0))
	return upgrade

func _roll_rarity() -> HandTypeUpgradeDefinition.UpgradeRarity:
	var roll := randf()
	if roll < 0.6:
		return HandTypeUpgradeDefinition.UpgradeRarity.COMMON
	if roll < 0.9:
		return HandTypeUpgradeDefinition.UpgradeRarity.RARE
	return HandTypeUpgradeDefinition.UpgradeRarity.EPIC

func _hand_type_label(hand_type: int) -> String:
	return HandEvaluatorService.HandType.keys()[hand_type].replace("_", " ").to_lower().capitalize()
