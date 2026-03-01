class_name ScoreCalculatorService

static func calculate(result: HandResult, values: Array[int], run_state: RunStateModel) -> int:
	if result == null or result.type == HandEvaluatorModel.HandType.INVALID:
		return 0

	var hand_base := HandScoringTable.get_base(result.type)
	hand_base += _sum_scoring_dice(values, result.scoring_indices)
	hand_base += run_state.get_total_hand_base_bonus(result.type)

	var total_mult := 1.0
	total_mult += HandScoringTable.get_mult(result.type)
	total_mult += run_state.get_total_multiplier_bonus()

	return int(round(float(hand_base) * total_mult))

static func _sum_scoring_dice(values: Array[int], scoring_indices: Array[int]) -> int:
	var total := 0
	for index in scoring_indices:
		if index >= 0 and index < values.size():
			total += values[index]
	return total
