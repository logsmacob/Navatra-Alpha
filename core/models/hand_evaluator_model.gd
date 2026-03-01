class_name HandEvaluatorModel

enum HandType {
	HIGH_CARD,
	ONE_PAIR,
	TWO_PAIR,
	THREE_OF_A_KIND,
	STRAIGHT,
	FULL_HOUSE,
	FOUR_OF_A_KIND,
	FIVE_OF_A_KIND,
	INVALID
}

# NOTE: Evaluates current dice values and returns a `HandResult`.
# Values are expected to be positive dice faces (1..N). Value `0` means unrolled.
static func evaluate(values: Array[int]) -> HandResult:
	var result := HandResult.new()

	if values.is_empty():
		result.type = HandType.INVALID
		result.is_complete = false
		result.note = "Cannot evaluate an empty hand."
		return result

	for value in values:
		if value <= 0:
			result.type = HandType.INVALID
			result.is_complete = false
			result.note = "Cannot evaluate hand with unrolled/invalid dice values."
			return result

	result.is_complete = true

	var value_to_indices: Dictionary = {}

	# NOTE: Build value -> indices map for frequency-based patterns.
	for i in range(values.size()):
		var v := values[i]
		if not value_to_indices.has(v):
			value_to_indices[v] = []
		value_to_indices[v].append(i)

	# NOTE: Collect and sort frequencies to identify pattern shape.
	var freqs: Array[int] = []
	for indices in value_to_indices.values():
		freqs.append(indices.size())
	freqs.sort()

	# NOTE: Straight check uses sorted unique values and strict +1 progression.
	# For standard 1..6 dice this detects 1-2-3-4-5 and 2-3-4-5-6 naturally.
	var sorted_vals := values.duplicate()
	sorted_vals.sort()

	var is_straight := true
	for i in range(1, sorted_vals.size()):
		if sorted_vals[i] != sorted_vals[i - 1] + 1:
			is_straight = false
			break

	# NOTE: Frequency-shape matching for hand classification.
	match freqs:
		[5]:
			result.type = HandType.FIVE_OF_A_KIND
			result.scoring_indices = _all_indices(values.size())

		[1, 4]:
			result.type = HandType.FOUR_OF_A_KIND
			result.scoring_indices = _largest_group(value_to_indices)

		[2, 3]:
			result.type = HandType.FULL_HOUSE
			result.scoring_indices = _all_indices(values.size())

		[1, 1, 3]:
			result.type = HandType.THREE_OF_A_KIND
			result.scoring_indices = _largest_group(value_to_indices)

		[1, 2, 2]:
			result.type = HandType.TWO_PAIR
			result.scoring_indices = _all_groups_of_size(value_to_indices, 2)

		[1, 1, 1, 2]:
			# NOTE: Explicit one-pair handling (previously missing).
			result.type = HandType.ONE_PAIR
			result.scoring_indices = _all_groups_of_size(value_to_indices, 2)

		[1, 1, 1, 1, 1]:
			if is_straight:
				result.type = HandType.STRAIGHT
				result.scoring_indices = _all_indices(values.size())
			else:
				result.type = HandType.HIGH_CARD
				result.scoring_indices = [_highest_index(values)]

		_:
			result.type = HandType.INVALID
			result.note = "Unrecognized frequency pattern."

	result.counts = value_to_indices
	if result.note.is_empty():
		result.note = "Evaluation completed successfully."
	return result


# -----------------------------
# Helpers
# -----------------------------

static func _all_indices(size: int) -> Array[int]:
	var arr: Array[int] = []
	for i in range(size):
		arr.append(i)
	return arr


static func _largest_group(map: Dictionary) -> Array[int]:
	var largest: Array[int] = []
	for indices in map.values():
		if indices.size() > largest.size():
			largest = indices
	return largest


static func _all_groups_of_size(map: Dictionary, group_size: int) -> Array[int]:
	var result: Array[int] = []
	for indices in map.values():
		if indices.size() == group_size:
			result.append_array(indices)
	return result


static func _highest_index(values: Array[int]) -> int:
	var max_val := values[0]
	var max_index := 0
	for i in range(1, values.size()):
		if values[i] > max_val:
			max_val = values[i]
			max_index = i
	return max_index
