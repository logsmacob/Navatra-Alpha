class_name RunRewardBalanceConfig
extends Resource

@export_group("Round Complete Marble Math")
@export_range(1.0, 1000.0, 1.0) var overflow_points_per_marble: float = 85.0
@export_range(0, 25, 1) var marbles_per_hand_remaining: int = 2
@export_range(0, 25, 1) var marbles_per_reroll_remaining: int = 2
@export_range(0, 99, 1) var progression_base_bonus: int = 2
@export_range(1, 99, 1) var progression_rounds_per_bonus_step: int = 3
@export_range(0, 99, 1) var minimum_round_reward: int = 1

func calculate_round_reward(overflow_points: int, hands_remaining: int, rerolls_remaining: int, round_index: int) -> int:
	var safe_overflow_points := max(overflow_points, 0)
	var overflow_currency := int(floor(float(safe_overflow_points) / overflow_points_per_marble))
	var hands_bonus := max(hands_remaining, 0) * marbles_per_hand_remaining
	var rerolls_bonus := max(rerolls_remaining, 0) * marbles_per_reroll_remaining
	var progression_bonus := progression_base_bonus + int(float(max(round_index - 1, 0)) / float(progression_rounds_per_bonus_step))
	return maxi(overflow_currency + hands_bonus + rerolls_bonus + progression_bonus, minimum_round_reward)
