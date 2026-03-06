extends Node

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

# NOTE: Handles evaluate hand.
func evaluate_hand(hand: Array[int]) -> HandType:
	if hand.size() == 0:
		return HandType.HIGH_DIE

	var counts := {}
	for value in hand:
		counts[value] = counts.get(value, 0) + 1

	var values := counts.values()
	values.sort()

	var sorted_hand := hand.duplicate()
	sorted_hand.sort()

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

	if hand.size() == 5:
		if sorted_hand == [1, 2, 3, 4, 5] or sorted_hand == [2, 3, 4, 5, 6]:
			return HandType.STRAIGHT

	return HandType.HIGH_DIE


# NOTE: Handles get hand details.
func get_hand_details(hand: Array[int]) -> HandDetails:
	var result := HandDetails.new(evaluate_hand(hand), [])

	if hand.size() == 0:
		return result

	var counts := {}
	for value in hand:
		counts[value] = counts.get(value, 0) + 1

	var keys := counts.keys()
	keys.sort()

	match result.type:
		HandType.HIGH_DIE:
			var sorted_hand := hand.duplicate()
			sorted_hand.sort()
			var highest_value = sorted_hand[-1]
			result.groups.append({"high_die": [highest_value]})
		HandType.ONE_PAIR:
			for k in keys:
				if counts[k] == 2:
					result.groups.append({"pair": [k, k]})
		HandType.TWO_PAIR:
			for k in keys:
				if counts[k] == 2:
					result.groups.append({"pair": [k, k]})
		HandType.THREE_OF_A_KIND:
			for k in keys:
				if counts[k] == 3:
					result.groups.append({"three_of_a_kind": [k, k, k]})
		HandType.FOUR_OF_A_KIND:
			for k in keys:
				if counts[k] == 4:
					result.groups.append({"four_of_a_kind": [k, k, k, k]})
		HandType.FIVE_OF_A_KIND:
			for k in keys:
				if counts[k] == 5:
					result.groups.append({"five_of_a_kind": [k, k, k, k, k]})
		HandType.FULL_HOUSE:
			for k in keys:
				if counts[k] == 3:
					result.groups.append({"three_of_a_kind": [k, k, k]})
				elif counts[k] == 2:
					result.groups.append({"pair": [k, k]})
		HandType.STRAIGHT:
			var sorted_straight := hand.duplicate()
			sorted_straight.sort()
			result.groups.append({"straight": sorted_straight})

	return result


# NOTE: Handles get hand type name.
func get_hand_type_name(hand: Array[int]) -> String:
	var type = evaluate_hand(hand)
	return HandType.keys()[type]


# NOTE: Handles get group dice values.
func get_group_dice_values(hand: Array[int]) -> Array[int]:
	var details := get_hand_details(hand)
	var dice_values: Array[int] = []

	for group in details.groups:
		var values: Array = group.values()[0]
		dice_values.append_array(values)

	return dice_values
