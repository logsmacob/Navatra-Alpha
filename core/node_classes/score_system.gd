extends Node

## Score system script: coordinates this part of the game's behavior.
class_name ScoreSystem

var _rules: HandScoreRulesService = HandScoreRulesService.new()

func calculate_score(details: HandDetails, scoring_context: HandScoringContext = null) -> int:
	if details == null:
		push_error("Invalid hand details passed to ScoreSystem")
		return 0

	if not _rules.has_hand_type(details.type):
		push_error("Hand type not defined in scoring rules")
		return 0

	var scoring_values := _rules.get_scoring_values(details.type, scoring_context)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))
	var group_contributions := _sum_group_contributions(details.groups)
	var group_total := int(group_contributions.get("base_total", 0))
	var group_mult_bonus := int(group_contributions.get("mult_bonus", 0))
	return (base + group_total) * (mult + group_mult_bonus)

func get_score_breakdown(details: HandDetails, scoring_context: HandScoringContext = null) -> Dictionary:
	if details == null:
		return {}

	var scoring_values := _rules.get_scoring_values(details.type, scoring_context)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))
	var group_contributions := _sum_group_contributions(details.groups)
	var group_total: int = int(group_contributions.get("base_total", 0))
	var group_mult_bonus: int = int(group_contributions.get("mult_bonus", 0))
	var final_mult := mult + group_mult_bonus

	return {
		"base": base,
		"group_total": group_total,
		"mult": final_mult,
		"final_score": (base + group_total) * final_mult,
	}

func get_type_only_total(details: HandDetails, scoring_context: HandScoringContext = null) -> int:
	if details == null:
		return 0
	if not _rules.has_hand_type(details.type):
		return 0

	var scoring_values := _rules.get_scoring_values(details.type, scoring_context)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))
	return base * mult

func _sum_group_contributions(groups: Array) -> Dictionary:
	var base_total := 0
	var mult_bonus := 0
	var modifiers := GameState.get_general_modifiers()
	for group_data in groups:
		for key in group_data.keys():
			var values: Array = group_data[key]
			for value in values:
				var face_value := int(value)
				base_total += _get_modified_face_value(face_value, modifiers)
				mult_bonus += _get_modified_face_mult(face_value, modifiers)
	return {
		"base_total": base_total,
		"mult_bonus": mult_bonus,
	}

func _get_modified_face_value(face_value: int, modifiers: Dictionary) -> int:
	var modifier_key := "base_%d_value" % face_value
	return int(modifiers.get(modifier_key, face_value))

func _get_modified_face_mult(face_value: int, modifiers: Dictionary) -> int:
	var modifier_key := "mult_%d_value" % face_value
	return int(modifiers.get(modifier_key, 0))
