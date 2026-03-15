extends RefCounted
class_name HandScoreRulesService

const DEFAULT_VALUES := {"base": 0, "mult": 0}
const HAND_VALUES := {
	0: {"base": 10, "mult": 1},
	1: {"base": 20, "mult": 2},
	2: {"base": 40, "mult": 3},
	3: {"base": 50, "mult": 4},
	4: {"base": 70, "mult": 8},
	5: {"base": 60, "mult": 6},
	6: {"base": 70, "mult": 10},
	7: {"base": 100, "mult": 14}
}

func has_hand_type(hand_type: int) -> bool:
	return HAND_VALUES.has(hand_type)

func get_scoring_values(hand_type: int) -> Dictionary:
	var values: Dictionary = HAND_VALUES.get(hand_type, DEFAULT_VALUES)
	var base_value: int = int(values.get("base", 0))
	var mult_value: int = int(values.get("mult", 0))

	if GameState != null and GameState.has_method("get_hand_type_upgrade"):
		var upgrade: Dictionary = GameState.get_hand_type_upgrade(hand_type)
		base_value += int(upgrade.get("base", 0))
		mult_value += int(upgrade.get("mult", 0))

	return {"base": base_value, "mult": mult_value}
