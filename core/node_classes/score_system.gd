# ScoreSystem
# ---------------------------------------------------------
# Responsible for calculating the final score of a hand.
# Uses a base value + the sum of card/group values,
# then multiplies the result by a hand-specific multiplier.
#
# Formula:
# final_score = (base + group_total) * multiplier
#
# This system expects a HandDetails object containing:
# - type   : the hand type (integer)
# - groups : array of dictionaries containing value arrays
# ---------------------------------------------------------

extends Node
class_name ScoreSystem

# ---------------------------------------------------------
# HAND_VALUES
# ---------------------------------------------------------
# Maps each HandType to its scoring rules.
#
# Formula used by ScoreSystem:
#
# final_score = (base + group_total) * multiplier
#
# base        → starting score for that hand
# group_total → sum of dice values from groups
# mult        → multiplier applied to the total
#
# Hand type reference:
#
# 0 HIGH_DIE
# 1 ONE_PAIR
# 2 TWO_PAIR
# 3 THREE_OF_A_KIND
# 4 STRAIGHT
# 5 FULL_HOUSE
# 6 FOUR_OF_A_KIND
# 7 FIVE_OF_A_KIND
# ---------------------------------------------------------
const HAND_VALUES := {

	# No combination — highest die only
	0: {"base": 10, "mult": 1},

	# Two dice match
	1: {"base": 20, "mult": 2},

	# Two separate pairs
	2: {"base": 40, "mult": 3},

	# Three dice match
	3: {"base": 50, "mult": 4},

	# Sequential run (1-5 or 2-6)
	4: {"base": 70, "mult": 8},

	# Three of a kind + a pair
	5: {"base": 60, "mult": 6},

	# Four dice match
	6: {"base": 70, "mult": 10},

	# All dice match (highest possible)
	7: {"base": 100, "mult": 14}
}



# ---------------------------------------------------------
# calculate_score()
# ---------------------------------------------------------
# Calculates the final score of a hand.
#
# Steps:
# 1. Validate the hand details
# 2. Look up the hand type in HAND_VALUES
# 3. Sum all card/group values
# 4. Apply the scoring formula
#
# Returns the final integer score.
# ---------------------------------------------------------
func calculate_score(details: HandDetails) -> int:

	# Safety check: ensure valid data was provided
	if details == null:
		push_error("Invalid hand details passed to ScoreSystem")
		return 0

	var hand_type: int = details.type

	# Ensure the hand type exists in our scoring table
	if not HAND_VALUES.has(hand_type):
		push_error("Hand type not defined in HAND_VALUES")
		return 0

	# Retrieve scoring data for this hand
	var scoring_values := _get_scoring_values(hand_type)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))

	# Sum values from all groups (pairs, kickers, etc.)
	var group_total := _sum_groups(details.groups)

	# Final scoring formula
	return (base + group_total) * mult


# ---------------------------------------------------------
# _sum_groups()
# ---------------------------------------------------------
# Private helper function.
#
# Iterates through all groups and sums every value found.
#
# Expected group structure example:
# [
#     {"pair": [10, 10]},
#     {"kicker": [5]}
# ]
#
# Result would be:
# 10 + 10 + 5 = 25
# ---------------------------------------------------------
func _sum_groups(groups: Array) -> int:
	var total := 0

	# Loop through each group dictionary
	for g in groups:

		# Each group may contain multiple keys
		for key in g.keys():

			# Each key maps to an array of values
			var values: Array = g[key]

			# Add each value to the total
			for v in values:
				total += v

	return total


# ---------------------------------------------------------
# get_score_breakdown()
# ---------------------------------------------------------
# Returns a detailed breakdown of how the final score
# was calculated.
#
# Useful for:
# - UI displays
# - debugging
# - tooltips
#
# Example return value:
# {
#     "base": 20,
#     "group_total": 15,
#     "mult": 2,
#     "final_score": 70
# }
# ---------------------------------------------------------
func get_score_breakdown(details: HandDetails) -> Dictionary:

	var hand_type: int = details.type

	var scoring_values := _get_scoring_values(hand_type)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))

	var group_total: int = _sum_groups(details.groups)

	var final_score: int = (base + group_total) * mult

	return {
		"base": base,
		"group_total": group_total,
		"mult": mult,
		"final_score": final_score
	}


# ---------------------------------------------------------
# get_type_only_total()
# ---------------------------------------------------------
# Calculates the score contribution from the hand type
# only, ignoring all card/group values.
#
# Useful for:
# - previews
# - comparing hand strengths
# - AI evaluation
#
# Formula:
# base * multiplier
# ---------------------------------------------------------
func get_type_only_total(details: HandDetails) -> int:

	# Safety check
	if details == null:
		return 0

	var hand_type: int = details.type

	# Ensure the type exists
	if not HAND_VALUES.has(hand_type):
		return 0

	var scoring_values := _get_scoring_values(hand_type)
	var base: int = int(scoring_values.get("base", 0))
	var mult: int = int(scoring_values.get("mult", 0))

	return base * mult


func _get_scoring_values(hand_type: int) -> Dictionary:
	var values: Dictionary = HAND_VALUES.get(hand_type, {"base": 0, "mult": 0})
	var base_value: int = int(values.get("base", 0))
	var mult_value: int = int(values.get("mult", 0))

	if GameState != null and GameState.has_method("get_hand_type_upgrade"):
		var upgrade: Dictionary = GameState.get_hand_type_upgrade(hand_type)
		base_value += int(upgrade.get("base", 0))
		mult_value += int(upgrade.get("mult", 0))

	return {"base": base_value, "mult": mult_value}
