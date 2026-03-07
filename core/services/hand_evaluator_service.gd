extends RefCounted
class_name HandEvaluatorService

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

func evaluate_hand(hand: Array[int]) -> HandType:
	if hand.is_empty():
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

func get_hand_details(hand: Array[int]) -> HandDetails:
	var result := HandDetails.new(evaluate_hand(hand), [])
	if hand.is_empty():
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
			for key in keys:
				if counts[key] == 2:
					result.groups.append({"pair": [key, key]})
		HandType.TWO_PAIR:
			for key in keys:
				if counts[key] == 2:
					result.groups.append({"pair": [key, key]})
		HandType.THREE_OF_A_KIND:
			for key in keys:
				if counts[key] == 3:
					result.groups.append({"three_of_a_kind": [key, key, key]})
		HandType.FOUR_OF_A_KIND:
			for key in keys:
				if counts[key] == 4:
					result.groups.append({"four_of_a_kind": [key, key, key, key]})
		HandType.FIVE_OF_A_KIND:
			for key in keys:
				if counts[key] == 5:
					result.groups.append({"five_of_a_kind": [key, key, key, key, key]})
		HandType.FULL_HOUSE:
			for key in keys:
				if counts[key] == 3:
					result.groups.append({"three_of_a_kind": [key, key, key]})
				elif counts[key] == 2:
					result.groups.append({"pair": [key, key]})
		HandType.STRAIGHT:
			var sorted_straight := hand.duplicate()
			sorted_straight.sort()
			result.groups.append({"straight": sorted_straight})

	return result

func get_hand_type_name(hand: Array[int]) -> String:
	var hand_type := evaluate_hand(hand)
	return HandType.keys()[hand_type]
