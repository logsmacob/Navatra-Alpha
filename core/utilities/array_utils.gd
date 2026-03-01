class_name ArrayUtils

# NOTE: Returns index of largest value, or -1 for empty arrays.
static func max_index(values: Array[int]) -> int:
	if values.is_empty():
		return -1

	var max_val := values[0]
	var index := 0
	for i in range(1, values.size()):
		if values[i] > max_val:
			max_val = values[i]
			index = i
	return index
