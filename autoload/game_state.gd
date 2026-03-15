extends Node
## Centralized, runtime-only game state.
##
## Runtime coordination stays here while hand mutation and round formulas
## are delegated to dedicated services to avoid a god-script singleton.

signal run_started(round_index: int)
signal round_started(round_index: int, quota: int, hands: int, rerolls: int)
signal round_state_changed(state: Dictionary)
signal round_completed(round_index: int)
signal reward_phase_started
signal run_failed(round_index: int)
signal currency_changed(amount: int)
signal player_hand_changed(hand_state: Array)

const BASE_DICE_PER_HAND: int = 5
const BASE_DIE_FACE_COUNT: int = 6

const DIE_MATERIAL_STANDARD := PlayerHandService.DIE_MATERIAL_STANDARD
const DIE_MATERIAL_GOLDEN := PlayerHandService.DIE_MATERIAL_GOLDEN
const DIE_MATERIAL_STEEL := PlayerHandService.DIE_MATERIAL_STEEL
const MATERIAL_CURRENCY_BONUS := PlayerHandService.MATERIAL_CURRENCY_BONUS

var round_index: int = 1
var quota_remaining: int = 0
var hands_remaining: int = 0
var rerolls_remaining: int = 0
var round_score_multiplier: float = 1.0
var currency: int = 0
var hand_type_upgrades: Dictionary = {}

var _next_round_hands_bonus: int = 0
var _next_round_rerolls_bonus: int = 0
var _next_round_quota_reduction: int = 0
var _next_round_score_multiplier_bonus: float = 0.0

var _player_hand_service: PlayerHandService = PlayerHandService.new()
var _round_progression_service: RoundProgressionService = RoundProgressionService.new()

func _ready() -> void:
	start_new_run()

func start_new_run() -> void:
	round_index = 1
	currency = 0
	hand_type_upgrades.clear()
	initialize_player_hand(BASE_DICE_PER_HAND, BASE_DIE_FACE_COUNT)
	_clear_pending_reward_bonuses()
	currency_changed.emit(currency)
	run_started.emit(round_index)
	start_round(round_index)

func start_next_round() -> void:
	round_index += 1
	start_round(round_index)

func start_round(target_round: int) -> void:
	var round_setup := _round_progression_service.build_round_state(target_round, _get_pending_bonus_state())
	quota_remaining = int(round_setup.get("quota_remaining", 0))
	hands_remaining = int(round_setup.get("hands_remaining", 0))
	rerolls_remaining = int(round_setup.get("rerolls_remaining", 0))
	round_score_multiplier = float(round_setup.get("round_score_multiplier", 1.0))
	_clear_pending_reward_bonuses()
	round_started.emit(target_round, quota_remaining, hands_remaining, rerolls_remaining)
	_emit_round_state()

func add_currency(amount: int) -> void:
	if amount <= 0:
		return
	currency += amount
	currency_changed.emit(currency)

func spend_currency(amount: int) -> bool:
	if amount <= 0:
		return true
	if currency < amount:
		return false
	currency -= amount
	currency_changed.emit(currency)
	return true

func initialize_player_hand(dice_count: int = BASE_DICE_PER_HAND, face_count: int = BASE_DIE_FACE_COUNT) -> void:
	_player_hand_service.initialize(dice_count, face_count)
	player_hand_changed.emit(get_player_hand())

func get_player_hand() -> Array[Dictionary]:
	return _player_hand_service.get_hand_copy()

func set_die_face_value(die_index: int, face_index: int, new_value: int) -> bool:
	var updated := _player_hand_service.set_die_face_value(die_index, face_index, new_value)
	if updated:
		player_hand_changed.emit(get_player_hand())
	return updated

func set_die_material(die_index: int, material: String) -> bool:
	var updated := _player_hand_service.set_die_material(die_index, material)
	if updated:
		player_hand_changed.emit(get_player_hand())
	return updated

func get_currency_bonus_for_hand_play() -> int:
	return _player_hand_service.get_currency_bonus_for_hand_play()

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

func get_round_state() -> Dictionary:
	return {
		"round_index": round_index,
		"quota_remaining": quota_remaining,
		"hands_remaining": hands_remaining,
		"rerolls_remaining": rerolls_remaining,
		"round_score_multiplier": round_score_multiplier,
		"currency": currency,
	}

func _emit_round_state() -> void:
	round_state_changed.emit(get_round_state())

func _evaluate_round_outcome() -> void:
	if is_round_complete():
		round_completed.emit(round_index)
		reward_phase_started.emit()
		return

	if hands_remaining <= 0:
		run_failed.emit(round_index)

func _get_pending_bonus_state() -> Dictionary:
	return {
		"hands_bonus": _next_round_hands_bonus,
		"rerolls_bonus": _next_round_rerolls_bonus,
		"quota_reduction": _next_round_quota_reduction,
		"score_multiplier_bonus": _next_round_score_multiplier_bonus,
	}

func _clear_pending_reward_bonuses() -> void:
	_next_round_hands_bonus = 0
	_next_round_rerolls_bonus = 0
	_next_round_quota_reduction = 0
	_next_round_score_multiplier_bonus = 0.0
