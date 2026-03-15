extends RefCounted
class_name RoundProgressionService

const BASE_QUOTA: int = 300
const QUOTA_GROWTH: float = 1.45
const BASE_HANDS_PER_ROUND: int = 3
const HANDS_SCALING_INTERVAL: int = 3
const BASE_REROLLS_PER_ROUND: int = 3

func build_round_state(target_round: int, bonuses: Dictionary) -> Dictionary:
	var quota_reduction := int(bonuses.get("quota_reduction", 0))
	var hands_bonus := int(bonuses.get("hands_bonus", 0))
	var rerolls_bonus := int(bonuses.get("rerolls_bonus", 0))
	var score_multiplier_bonus := float(bonuses.get("score_multiplier_bonus", 0.0))

	return {
		"quota_remaining": max(_calculate_quota(target_round) - quota_reduction, 0),
		"hands_remaining": _calculate_hands(target_round) + hands_bonus,
		"rerolls_remaining": BASE_REROLLS_PER_ROUND + rerolls_bonus,
		"round_score_multiplier": 1.0 + score_multiplier_bonus,
	}

func _calculate_quota(target_round: int) -> int:
	return int(round(BASE_QUOTA * pow(QUOTA_GROWTH, target_round - 1)))

func _calculate_hands(target_round: int) -> int:
	return BASE_HANDS_PER_ROUND + int((target_round - 1) / float(HANDS_SCALING_INTERVAL))
