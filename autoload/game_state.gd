extends Node
## Centralized, runtime-only game state.
##
## Why this exists:
## - keeps round/run rules in one place
## - avoids scattering "magic numbers" through scene scripts
## - makes feature additions (shop, trinkets, scaling tweaks) safer

signal run_started(round_index: int)
signal round_started(round_index: int, quota: int, hands: int, rerolls: int)
signal round_state_changed(state: Dictionary)
signal round_completed(round_index: int)
signal reward_phase_started
signal run_failed(round_index: int)

const BASE_QUOTA: int = 300
const QUOTA_GROWTH: float = 1.45
const BASE_HANDS_PER_ROUND: int = 3
const HANDS_SCALING_INTERVAL: int = 3
const BASE_REROLLS_PER_ROUND: int = 3

var round_index: int = 1
var quota_remaining: int = 0
var hands_remaining: int = 0
var rerolls_remaining: int = 0
var round_score_multiplier: float = 1.0
var _next_round_hands_bonus: int = 0
var _next_round_rerolls_bonus: int = 0
var _next_round_quota_reduction: int = 0
var _next_round_score_multiplier_bonus: float = 0.0
var hand_type_upgrades: Dictionary = {}

func _ready() -> void:
	start_new_run()

func start_new_run() -> void:
	round_index = 1
	hand_type_upgrades.clear()
	_clear_pending_reward_bonuses()
	run_started.emit(round_index)
	start_round(round_index)

func start_next_round() -> void:
	round_index += 1
	start_round(round_index)

func start_round(target_round: int) -> void:
	quota_remaining = max(_calculate_quota(target_round) - _next_round_quota_reduction, 0)
	hands_remaining = _calculate_hands(target_round) + _next_round_hands_bonus
	rerolls_remaining = BASE_REROLLS_PER_ROUND + _next_round_rerolls_bonus
	round_score_multiplier = 1.0 + _next_round_score_multiplier_bonus
	_clear_pending_reward_bonuses()
	round_started.emit(target_round, quota_remaining, hands_remaining, rerolls_remaining)
	_emit_round_state()

func add_next_round_hands_bonus(amount: int) -> void:
	_next_round_hands_bonus += max(amount, 0)

func add_next_round_rerolls_bonus(amount: int) -> void:
	_next_round_rerolls_bonus += max(amount, 0)

func add_next_round_quota_reduction(amount: int) -> void:
	_next_round_quota_reduction += max(amount, 0)

func add_next_round_score_multiplier_bonus(amount: float) -> void:
	_next_round_score_multiplier_bonus += max(amount, 0.0)


func add_hand_type_upgrade(hand_type: int, base_bonus: int, mult_bonus: int) -> void:
	if not hand_type_upgrades.has(hand_type):
		hand_type_upgrades[hand_type] = {"base": 0, "mult": 0}

	var upgrade_data: Dictionary = hand_type_upgrades[hand_type]
	upgrade_data["base"] = int(upgrade_data.get("base", 0)) + max(base_bonus, 0)
	upgrade_data["mult"] = int(upgrade_data.get("mult", 0)) + max(mult_bonus, 0)
	hand_type_upgrades[hand_type] = upgrade_data

func get_hand_type_upgrade(hand_type: int) -> Dictionary:
	if not hand_type_upgrades.has(hand_type):
		return {"base": 0, "mult": 0}
	return hand_type_upgrades[hand_type].duplicate()

func consume_reroll() -> bool:
	if rerolls_remaining <= 0:
		return false
	rerolls_remaining -= 1
	_emit_round_state()
	return true

func apply_score_to_quota(score: int) -> void:
	quota_remaining = max(quota_remaining - score, 0)
	_emit_round_state()

func consume_hand() -> void:
	hands_remaining = max(hands_remaining - 1, 0)
	_emit_round_state()
	_evaluate_round_outcome()

func is_round_complete() -> bool:
	return quota_remaining <= 0

func can_continue_round() -> bool:
	return quota_remaining > 0 and hands_remaining > 0

func _calculate_quota(target_round: int) -> int:
	return int(round(BASE_QUOTA * pow(QUOTA_GROWTH, target_round - 1)))

func _calculate_hands(target_round: int) -> int:
	return BASE_HANDS_PER_ROUND + int((target_round - 1) / float(HANDS_SCALING_INTERVAL))

func _emit_round_state() -> void:
	round_state_changed.emit(get_round_state())

func get_round_state() -> Dictionary:
	return {
		"round_index": round_index,
		"quota_remaining": quota_remaining,
		"hands_remaining": hands_remaining,
		"rerolls_remaining": rerolls_remaining,
		"round_score_multiplier": round_score_multiplier,
	}

func _evaluate_round_outcome() -> void:
	if is_round_complete():
		round_completed.emit(round_index)
		reward_phase_started.emit()
		return

	if hands_remaining <= 0:
		run_failed.emit(round_index)

func _clear_pending_reward_bonuses() -> void:
	_next_round_hands_bonus = 0
	_next_round_rerolls_bonus = 0
	_next_round_quota_reduction = 0
	_next_round_score_multiplier_bonus = 0.0
