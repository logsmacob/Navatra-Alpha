extends RefCounted

## Round progression service script: coordinates this part of the game's behavior.
class_name RoundProgressionService

const BASE_QUOTA: int = 260
const QUOTA_GROWTH: float = 1.26
const BASE_HANDS_PER_ROUND: int = 3
const HANDS_SCALING_INTERVAL: int = 6
const BASE_REROLLS_PER_ROUND: int = 3

func build_round_state(target_round: int, bonuses: Dictionary, general_modifiers: Dictionary = {}) -> Dictionary:
	var quota_reduction := int(bonuses.get("quota_reduction", 0))
	var hands_bonus := int(bonuses.get("hands_bonus", 0))
	var rerolls_bonus := int(bonuses.get("rerolls_bonus", 0))
	var score_multiplier_bonus := float(bonuses.get("score_multiplier_bonus", 0.0))
	var playable_hands := int(general_modifiers.get("shop_playable_hands", BASE_HANDS_PER_ROUND))
	var available_rerolls := int(general_modifiers.get("shop_rerolls", BASE_REROLLS_PER_ROUND))

	return {
		"quota_remaining": max(_calculate_quota(target_round) - quota_reduction, 0),
		"hands_remaining": playable_hands + int((target_round - 1) / float(HANDS_SCALING_INTERVAL)) + hands_bonus,
		"rerolls_remaining": available_rerolls + rerolls_bonus,
		"round_score_multiplier": 1.0 + score_multiplier_bonus,
	}

func _calculate_quota(target_round: int) -> int:
	return int(round(BASE_QUOTA * pow(QUOTA_GROWTH, target_round - 1)))
