# HandEvaluatorService
# ---------------------------------------------------------
# Responsible for determining what type of hand a player has.
#
# Input:
#    Array[int] representing dice values.
#
# Example hand:
#    [2, 2, 5, 5, 5]
#
# Output:
#    A HandType enum value representing the best hand found.
#
# This service also builds a HandDetails object which
# ScoreSystem later uses to calculate the final score.
# ---------------------------------------------------------

extends RefCounted
class_name HandEvaluatorService


# ---------------------------------------------------------
# HandType Enum
# ---------------------------------------------------------
# Defines every possible hand the system recognizes.
#
# These map directly to ScoreSystem.HAND_VALUES.
#
# Ranking from weakest → strongest:
#
# HIGH_DIE        : No combinations, only highest die counts
# ONE_PAIR        : Two dice of the same value
# TWO_PAIR        : Two different pairs
# THREE_OF_A_KIND : Three dice with the same value
# STRAIGHT        : Sequential values (1-5 or 2-6)
# FULL_HOUSE      : Three of one value + two of another
# FOUR_OF_A_KIND  : Four dice with the same value
# FIVE_OF_A_KIND  : All five dice identical
# ---------------------------------------------------------
enum HandType {
	HIGH_DIE,
	ONE_PAIR,
	TWO_PAIR,
	THREE_OF_A_KIND,
	STRAIGHT,
	FULL_HOUSE,
	FOUR_OF_A_KIND,
	FIVE_OF_A_KIND
}


# ---------------------------------------------------------
# evaluate_hand()
# ---------------------------------------------------------
# Determines which hand type the dice represent.
#
# Steps:
# 1. Count how many times each value appears
# 2. Analyze those counts
# 3. Match them to a known hand pattern
#
# Example counts for:
# [2,2,5,5,5]
#
# counts = {2:2, 5:3}
# values = [2,3]
#
# Which equals FULL_HOUSE.
# ---------------------------------------------------------
func evaluate_hand(hand: Array[int]) -> HandType:

	# Empty hand defaults to HIGH_DIE
	if hand.is_empty():
		return HandType.HIGH_DIE

	# Count occurrences of each die value
	var counts := {}
	for value in hand:
		counts[value] = counts.get(value, 0) + 1

	# Extract the counts and sort them
	# Example: [2,3], [1,4], [5]
	var values := counts.values()
	values.sort()

	# Sort the hand for straight detection
	var sorted_hand := hand.duplicate()
	sorted_hand.sort()

	# -------------------------------------------------
	# Detect specific hand types based on counts
	# -------------------------------------------------

	if values == [5]:
		return HandType.FIVE_OF_A_KIND

	if values == [1, 4]:
		return HandType.FOUR_OF_A_KIND

	if values == [2, 3]:
		return HandType.FULL_HOUSE

	if values == [1, 1, 3]:
		return HandType.THREE_OF_A_KIND

	if values == [1, 2, 2]:
		return HandType.TWO_PAIR

	if values == [1, 1, 1, 2]:
		return HandType.ONE_PAIR

	# -------------------------------------------------
	# Straight detection
	# Requires exactly 5 dice
	# -------------------------------------------------
	if hand.size() == 5:
		if sorted_hand == [1, 2, 3, 4, 5] or sorted_hand == [2, 3, 4, 5, 6]:
			return HandType.STRAIGHT

	# Default fallback
	return HandType.HIGH_DIE


# ---------------------------------------------------------
# get_hand_details()
# ---------------------------------------------------------
# Creates a HandDetails object describing the hand.
#
# HandDetails contains:
#
# type   → the HandType
# groups → structured value groups used for scoring
#
# Example FULL_HOUSE result:
#
# groups = [
#   {"three_of_a_kind": [5,5,5]},
#   {"pair": [2,2]}
# ]
#
# ScoreSystem later sums these values to compute score.
# ---------------------------------------------------------
func get_hand_details(hand: Array[int]) -> HandDetails:

	var result := HandDetails.new(evaluate_hand(hand), [])

	if hand.is_empty():
		return result

	# Count occurrences again
	var counts := {}
	for value in hand:
		counts[value] = counts.get(value, 0) + 1

	var keys := counts.keys()
	keys.sort()

	match result.type:

		# -------------------------
		# HIGH DIE
		# -------------------------
		# Only the highest die counts
		HandType.HIGH_DIE:
			var sorted_hand := hand.duplicate()
			sorted_hand.sort()
			var highest_value = sorted_hand[-1]

			result.groups.append({
				"high_die": [highest_value]
			})

		# -------------------------
		# ONE PAIR
		# -------------------------
		HandType.ONE_PAIR:
			for key in keys:
				if counts[key] == 2:
					result.groups.append({
						"pair": [key, key]
					})

		# -------------------------
		# TWO PAIR
		# -------------------------
		HandType.TWO_PAIR:
			for key in keys:
				if counts[key] == 2:
					result.groups.append({
						"pair": [key, key]
					})

		# -------------------------
		# THREE OF A KIND
		# -------------------------
		HandType.THREE_OF_A_KIND:
			for key in keys:
				if counts[key] == 3:
					result.groups.append({
						"three_of_a_kind": [key, key, key]
					})

		# -------------------------
		# FOUR OF A KIND
		# -------------------------
		HandType.FOUR_OF_A_KIND:
			for key in keys:
				if counts[key] == 4:
					result.groups.append({
						"four_of_a_kind": [key, key, key, key]
					})

		# -------------------------
		# FIVE OF A KIND
		# -------------------------
		HandType.FIVE_OF_A_KIND:
			for key in keys:
				if counts[key] == 5:
					result.groups.append({
						"five_of_a_kind": [key, key, key, key, key]
					})

		# -------------------------
		# FULL HOUSE
		# -------------------------
		HandType.FULL_HOUSE:
			for key in keys:
				if counts[key] == 3:
					result.groups.append({
						"three_of_a_kind": [key, key, key]
					})
				elif counts[key] == 2:
					result.groups.append({
						"pair": [key, key]
					})

		# -------------------------
		# STRAIGHT
		# -------------------------
		HandType.STRAIGHT:
			var sorted_straight := hand.duplicate()
			sorted_straight.sort()

			result.groups.append({
				"straight": sorted_straight
			})

	return result


# ---------------------------------------------------------
# get_hand_type_name()
# ---------------------------------------------------------
# Converts a hand type into a readable string.
#
# Example:
#    [2,2,3,3,3] → "FULL_HOUSE"
# ---------------------------------------------------------
func get_hand_type_name(hand: Array[int]) -> String:

	var hand_type := evaluate_hand(hand)

	return HandType.keys()[hand_type]
