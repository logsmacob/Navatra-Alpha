class_name HandScoringTable

# NOTE: Foundation values that can later be moved to external resources.
# The keys are HandEvaluatorModel.HandType values.
const BASE_BY_TYPE := {
	HandEvaluatorModel.HandType.HIGH_DIE: 2,
	HandEvaluatorModel.HandType.ONE_PAIR: 5,
	HandEvaluatorModel.HandType.TWO_PAIR: 9,
	HandEvaluatorModel.HandType.THREE_OF_A_KIND: 13,
	HandEvaluatorModel.HandType.STRAIGHT: 20,
	HandEvaluatorModel.HandType.FULL_HOUSE: 24,
	HandEvaluatorModel.HandType.FOUR_OF_A_KIND: 30,
	HandEvaluatorModel.HandType.FIVE_OF_A_KIND: 45
}

const MULT_BY_TYPE := {
	HandEvaluatorModel.HandType.HIGH_DIE: 0.0,
	HandEvaluatorModel.HandType.ONE_PAIR: 0.1,
	HandEvaluatorModel.HandType.TWO_PAIR: 0.25,
	HandEvaluatorModel.HandType.THREE_OF_A_KIND: 0.5,
	HandEvaluatorModel.HandType.STRAIGHT: 0.8,
	HandEvaluatorModel.HandType.FULL_HOUSE: 1.0,
	HandEvaluatorModel.HandType.FOUR_OF_A_KIND: 1.5,
	HandEvaluatorModel.HandType.FIVE_OF_A_KIND: 2.5
}

static func get_base(hand_type: int) -> int:
	if not BASE_BY_TYPE.has(hand_type):
		return 0
	return BASE_BY_TYPE[hand_type]

static func get_mult(hand_type: int) -> float:
	if not MULT_BY_TYPE.has(hand_type):
		return 0.0
	return MULT_BY_TYPE[hand_type]
