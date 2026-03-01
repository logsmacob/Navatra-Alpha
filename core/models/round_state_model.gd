class_name RoundStateModel

# NOTE: Runtime state for a single round.
var round_index: int = 1
var starting_quota: int = 0
var current_quota: int = 0

var hands_total: int = 0
var hands_remaining: int = 0

var rerolls_total: int = 0
var rerolls_remaining: int = 0

func configure(p_round_index: int, p_quota: int, p_hands: int, p_rerolls: int) -> void:
	round_index = max(1, p_round_index)
	starting_quota = max(0, p_quota)
	current_quota = starting_quota

	hands_total = max(0, p_hands)
	hands_remaining = hands_total

	rerolls_total = max(0, p_rerolls)
	rerolls_remaining = rerolls_total

func can_play_hand() -> bool:
	return hands_remaining > 0 and current_quota > 0

func can_reroll() -> bool:
	return rerolls_remaining > 0

func spend_reroll() -> bool:
	if rerolls_remaining <= 0:
		return false
	rerolls_remaining -= 1
	return true

func consume_hand() -> bool:
	if hands_remaining <= 0:
		return false
	hands_remaining -= 1
	return true

func apply_score(score: int) -> void:
	current_quota = max(0, current_quota - max(0, score))

func is_cleared() -> bool:
	return current_quota <= 0

func is_failed() -> bool:
	return hands_remaining <= 0 and current_quota > 0
