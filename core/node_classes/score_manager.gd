extends Node

## Score manager script: coordinates this part of the game's behavior.
class_name ScoreManager

var current_score: int = 0
var last_roll_score: int = 0
var last_type_total: int = 0
var last_details: HandDetails = null
var last_breakdown: Dictionary = {}
var play_pending: bool = false
var score_system := ScoreSystem.new()
var hand_evaluator: HandEvaluatorService = HandEvaluatorService.new()

func configure(evaluator: HandEvaluatorService) -> void:
	hand_evaluator = evaluator

# NOTE: Handles preview hand.
func preview_hand(hand: Array[int]) -> void:
	last_details = hand_evaluator.get_hand_details(hand)

	if last_details.groups.is_empty():
		last_roll_score = 0
		last_type_total = 0
		last_breakdown = {}
		EventBus.score_calculated.emit(last_details, 0, {})
		return

	last_roll_score = score_system.calculate_score(last_details)
	last_type_total = score_system.get_type_only_total(last_details)
	last_breakdown = score_system.get_score_breakdown(last_details)
	last_breakdown["type_total"] = last_type_total
	last_breakdown["hand_name"] = HandEvaluatorService.HandType.keys()[last_details.type]

	EventBus.hand_evaluated.emit(last_details)
	EventBus.score_calculated.emit(last_details, last_type_total, last_breakdown)


# NOTE: Handles can play hand.
func can_play_hand() -> bool:
	return last_roll_score > 0 and not play_pending


# NOTE: Handles play hand.
func play_hand() -> int:
	if not can_play_hand():
		return 0

	play_pending = true
	return last_type_total


# NOTE: Handles commit played hand.
func commit_played_hand() -> int:
	if not play_pending:
		return 0

	var applied_round_score := int(round(last_roll_score * GameState.round_score_multiplier))
	current_score += applied_round_score

	EventBus.round_score_applied.emit(applied_round_score)
	EventBus.score_committed.emit(current_score)

	last_roll_score = 0
	last_type_total = 0
	last_details = null
	last_breakdown = {}
	play_pending = false

	return applied_round_score


# NOTE: Handles get last details.
func get_last_details() -> HandDetails:
	return last_details


# NOTE: Handles get last breakdown.
func get_last_breakdown() -> Dictionary:
	return last_breakdown.duplicate(true)
