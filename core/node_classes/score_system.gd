extends Node
class_name ScoreSystem

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

# NOTE: Handles calculate score.
func calculate_score(details: HandDetails) -> int:
	if details == null:
		push_error("Invalid hand details passed to ScoreSystem")
		return 0

	var hand_type: int = details.type
	if not HAND_VALUES.has(hand_type):
		push_error("Hand type not defined in HAND_VALUES")
		return 0

	var base: int = HAND_VALUES[hand_type]["base"]
	var mult: int = HAND_VALUES[hand_type]["mult"]
	var group_total := _sum_groups(details.groups)
	return (base + group_total) * mult


# NOTE: Handles sum groups.
func _sum_groups(groups: Array) -> int:
	var total := 0
	for g in groups:
		for key in g.keys():
			var values: Array = g[key]
			for v in values:
				total += v
	return total


# NOTE: Handles get score breakdown.
func get_score_breakdown(details: HandDetails) -> Dictionary:
	var hand_type: int = details.type
	var base: int = HAND_VALUES[hand_type]["base"]
	var mult: int = HAND_VALUES[hand_type]["mult"]
	var group_total: int = _sum_groups(details.groups)
	var final_score: int = (base + group_total) * mult

	return {
		"base": base,
		"group_total": group_total,
		"mult": mult,
		"final_score": final_score
	}


# NOTE: Handles get type only total.
func get_type_only_total(details: HandDetails) -> int:
	if details == null:
		return 0

	var hand_type: int = details.type
	if not HAND_VALUES.has(hand_type):
		return 0

	var base: int = HAND_VALUES[hand_type]["base"]
	var mult: int = HAND_VALUES[hand_type]["mult"]
	return base * mult
