class_name GameBalanceConfig

# NOTE: Explicit balance levers captured from README TODOs.
const BASE_QUOTA: int = 100
const QUOTA_GROWTH_RATE: float = 1.45

const BASE_HANDS_PER_ROUND: int = 4
const HANDS_GAIN_EVERY_N_ROUNDS: int = 3

const BASE_REROLLS_PER_ROUND: int = 3

static func get_hands_for_round(round_index: int) -> int:
	var normalized_round: int = maxi(1, round_index)
	var bonus_hands: int = roundi(float(normalized_round - 1) / HANDS_GAIN_EVERY_N_ROUNDS)
	return BASE_HANDS_PER_ROUND + bonus_hands
