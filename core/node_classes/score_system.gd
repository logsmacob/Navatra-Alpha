extends Node
class_name ScoreSystem

var _rules: HandScoreRulesService = HandScoreRulesService.new()

func calculate_score(details: HandDetails) -> int:
	if details == null:
		push_error("Invalid hand details passed to ScoreSystem")
		return 0

	if not _rules.has_hand_type(details.type):
		push_error("Hand type not defined in scoring rules")
		return 0

	var scoring_values := _rules.get_scoring_values(details.type)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))
	var group_total := _sum_groups(details.groups)
	return (base + group_total) * mult

func get_score_breakdown(details: HandDetails) -> Dictionary:
	if details == null:
		return {}

	var scoring_values := _rules.get_scoring_values(details.type)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))
	var group_total: int = _sum_groups(details.groups)

	return {
		"base": base,
		"group_total": group_total,
		"mult": mult,
		"final_score": (base + group_total) * mult
	}

func get_type_only_total(details: HandDetails) -> int:
	if details == null:
		return 0
	if not _rules.has_hand_type(details.type):
		return 0

	var scoring_values := _rules.get_scoring_values(details.type)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))
	return base * mult

func _sum_groups(groups: Array) -> int:
	var total := 0
	for group_data in groups:
		for key in group_data.keys():
			var values: Array = group_data[key]
			for value in values:
				total += value
	return total
