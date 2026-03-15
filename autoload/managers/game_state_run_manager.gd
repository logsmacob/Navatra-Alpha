extends RefCounted
class_name GameStateRunManager

const MAX_ROUNDS: int = 18

var round_index: int = 1
var quota_remaining: int = 0
var hands_remaining: int = 0
var rerolls_remaining: int = 0
var round_score_multiplier: float = 1.0
var currency: int = 0
var total_score: int = 0
var total_hands_played: int = 0
var total_rerolls_used: int = 0
var total_currency_earned: int = 0
var rounds_cleared: int = 0

var _next_round_hands_bonus: int = 0
var _next_round_rerolls_bonus: int = 0
var _next_round_quota_reduction: int = 0
var _next_round_score_multiplier_bonus: float = 0.0

var _round_progression_service: RoundProgressionService = RoundProgressionService.new()

func reset_run() -> void:
	round_index = 1
	currency = 0
	total_score = 0
	total_hands_played = 0
	total_rerolls_used = 0
	total_currency_earned = 0
	rounds_cleared = 0
	clear_pending_reward_bonuses()

func can_start_next_round() -> bool:
	return round_index < MAX_ROUNDS

func advance_to_next_round() -> bool:
	if not can_start_next_round():
		return false
	round_index += 1
	return true

func start_round(target_round: int) -> Dictionary:
	var round_setup := _round_progression_service.build_round_state(target_round, get_pending_bonus_state())
	quota_remaining = int(round_setup.get("quota_remaining", 0))
	hands_remaining = int(round_setup.get("hands_remaining", 0))
	rerolls_remaining = int(round_setup.get("rerolls_remaining", 0))
	round_score_multiplier = float(round_setup.get("round_score_multiplier", 1.0))
	clear_pending_reward_bonuses()
	return get_round_state()

func add_currency(amount: int) -> bool:
	if amount <= 0:
		return false
	currency += amount
	total_currency_earned += amount
	return true

func spend_currency(amount: int) -> bool:
	if amount <= 0:
		return true
	if currency < amount:
		return false
	currency -= amount
	return true

func consume_reroll() -> bool:
	if rerolls_remaining <= 0:
		return false
	rerolls_remaining -= 1
	total_rerolls_used += 1
	return true

func process_played_hand(score: int) -> Dictionary:
	var safe_score: int = maxi(score, 0)
	var quota_before := quota_remaining
	quota_remaining = max(quota_remaining - safe_score, 0)
	total_score += safe_score
	total_hands_played += 1
	hands_remaining = max(hands_remaining - 1, 0)

	if quota_remaining <= 0:
		rounds_cleared += 1
		var overflow_points: int = maxi(safe_score - quota_before, 0)
		var round_reward := calculate_round_reward(overflow_points)
		return {
			"round_cleared": true,
			"round_reward": round_reward,
			"run_won": round_index >= MAX_ROUNDS,
		}

	if hands_remaining <= 0:
		return {"run_failed": true}

	return {}

func add_next_round_hands_bonus(amount: int) -> void:
	_next_round_hands_bonus += max(amount, 0)

func add_next_round_rerolls_bonus(amount: int) -> void:
	_next_round_rerolls_bonus += max(amount, 0)

func add_next_round_quota_reduction(amount: int) -> void:
	_next_round_quota_reduction += max(amount, 0)

func add_next_round_score_multiplier_bonus(amount: float) -> void:
	_next_round_score_multiplier_bonus += max(amount, 0.0)

func is_round_complete() -> bool:
	return quota_remaining <= 0

func can_continue_round() -> bool:
	return quota_remaining > 0 and hands_remaining > 0

func get_round_state() -> Dictionary:
	return {
		"round_index": round_index,
		"quota_remaining": quota_remaining,
		"hands_remaining": hands_remaining,
		"rerolls_remaining": rerolls_remaining,
		"round_score_multiplier": round_score_multiplier,
		"currency": currency,
	}

func get_run_stats() -> Dictionary:
	return {
		"final_round": round_index,
		"max_round": MAX_ROUNDS,
		"rounds_cleared": rounds_cleared,
		"total_score": total_score,
		"total_hands_played": total_hands_played,
		"total_rerolls_used": total_rerolls_used,
		"currency_earned": total_currency_earned,
		"currency_remaining": currency,
	}

func calculate_round_reward(overflow_points: int) -> int:
	var overflow_currency := int(floor(float(overflow_points) / 85.0))
	var hands_bonus := hands_remaining * 2
	var rerolls_bonus := rerolls_remaining * 2
	var progression_bonus := 2 + int(float(round_index - 1) / 3)
	return maxi(overflow_currency + hands_bonus + rerolls_bonus + progression_bonus, 1)

func get_pending_bonus_state() -> Dictionary:
	return {
		"hands_bonus": _next_round_hands_bonus,
		"rerolls_bonus": _next_round_rerolls_bonus,
		"quota_reduction": _next_round_quota_reduction,
		"score_multiplier_bonus": _next_round_score_multiplier_bonus,
	}

func clear_pending_reward_bonuses() -> void:
	_next_round_hands_bonus = 0
	_next_round_rerolls_bonus = 0
	_next_round_quota_reduction = 0
	_next_round_score_multiplier_bonus = 0.0
