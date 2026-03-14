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
signal currency_changed(amount: int)
signal player_hand_changed(hand_state: Array)

const BASE_QUOTA: int = 300
const QUOTA_GROWTH: float = 1.45
const BASE_HANDS_PER_ROUND: int = 3
const HANDS_SCALING_INTERVAL: int = 3
const BASE_REROLLS_PER_ROUND: int = 3
const BASE_DICE_PER_HAND: int = 5
const BASE_DIE_FACE_COUNT: int = 6

const DIE_MATERIAL_STANDARD := "standard"
const DIE_MATERIAL_GOLDEN := "golden"
const DIE_MATERIAL_STEEL := "steel"

const MATERIAL_CURRENCY_BONUS := {
	DIE_MATERIAL_STANDARD: 0,
	DIE_MATERIAL_GOLDEN: 2,
	DIE_MATERIAL_STEEL: 1,
}

var round_index: int = 1
var quota_remaining: int = 0
var hands_remaining: int = 0
var rerolls_remaining: int = 0
var round_score_multiplier: float = 1.0
var currency: int = 0
var player_hand: Array[Dictionary] = []
var _next_round_hands_bonus: int = 0
var _next_round_rerolls_bonus: int = 0
var _next_round_quota_reduction: int = 0
var _next_round_score_multiplier_bonus: float = 0.0
var hand_type_upgrades: Dictionary = {}

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
	quota_remaining = max(_calculate_quota(target_round) - _next_round_quota_reduction, 0)
	hands_remaining = _calculate_hands(target_round) + _next_round_hands_bonus
	rerolls_remaining = BASE_REROLLS_PER_ROUND + _next_round_rerolls_bonus
	round_score_multiplier = 1.0 + _next_round_score_multiplier_bonus
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
	player_hand.clear()
	for _i in range(max(dice_count, 0)):
		var faces: Array[int] = []
		for value in range(1, max(face_count, 0) + 1):
			faces.append(value)
		player_hand.append({
			"faces": faces,
			"material": DIE_MATERIAL_STANDARD,
		})
	player_hand_changed.emit(get_player_hand())

func get_player_hand() -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for die_data in player_hand:
		copy.append({
			"faces": (die_data.get("faces", []) as Array).duplicate(),
			"material": str(die_data.get("material", DIE_MATERIAL_STANDARD)),
		})
	return copy

func set_die_face_value(die_index: int, face_index: int, new_value: int) -> bool:
	if not _is_valid_die_index(die_index):
		return false
	if new_value < 1 or new_value > 6:
		return false

	var die_data := player_hand[die_index]
	var faces: Array = die_data.get("faces", [])
	if face_index < 0 or face_index >= faces.size():
		return false

	faces[face_index] = new_value
	die_data["faces"] = faces
	player_hand[die_index] = die_data
	player_hand_changed.emit(get_player_hand())
	return true

func set_die_material(die_index: int, material: String) -> bool:
	if not _is_valid_die_index(die_index):
		return false
	if not MATERIAL_CURRENCY_BONUS.has(material):
		return false

	var die_data := player_hand[die_index]
	die_data["material"] = material
	player_hand[die_index] = die_data
	player_hand_changed.emit(get_player_hand())
	return true

func get_currency_bonus_for_hand_play() -> int:
	var bonus: int = 0
	for die_data in player_hand:
		var material := str(die_data.get("material", DIE_MATERIAL_STANDARD))
		bonus += int(MATERIAL_CURRENCY_BONUS.get(material, 0))
	return bonus

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
		"currency": currency,
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

func _is_valid_die_index(die_index: int) -> bool:
	return die_index >= 0 and die_index < player_hand.size()
