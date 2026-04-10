extends Node
## Centralized, runtime-only game state coordinator.
##
## High-level orchestration stays in this autoload while specialized managers
## own player/dice state and run progression state.

signal run_started(round_index: int)
signal round_started(round_index: int, quota: int, hands: int, rerolls: int)
signal round_state_changed(state: Dictionary)
signal round_completed(round_index: int)
signal reward_phase_started
signal run_failed(round_index: int)
signal run_won(round_index: int, stats: Dictionary)
signal currency_changed(amount: int)
signal player_hand_changed(hand_state: Array)
signal general_modifiers_changed(modifiers: Dictionary)
signal hand_type_upgrades_changed(upgrades: Dictionary)

const BASE_DICE_PER_HAND: int = 5
const BASE_DIE_FACE_COUNT: int = 6
const MAX_ROUNDS: int = GameStateRunManager.MAX_ROUNDS

const DIE_MATERIAL_STANDARD := GameStatePlayerManager.DIE_MATERIAL_STANDARD
const DIE_MATERIAL_MARBLE := GameStatePlayerManager.DIE_MATERIAL_MARBLE
const DIE_MATERIAL_BLUE := GameStatePlayerManager.DIE_MATERIAL_BLUE
const DIE_MATERIAL_PINK := GameStatePlayerManager.DIE_MATERIAL_PINK
const MATERIAL_CURRENCY_BONUS := GameStatePlayerManager.MATERIAL_CURRENCY_BONUS
const DEFAULT_GENERAL_MODIFIERS := GameStatePlayerManager.DEFAULT_GENERAL_MODIFIERS

var round_index: int:
	get:
		return _run_manager.round_index

var quota_remaining: int:
	get:
		return _run_manager.quota_remaining

var hands_remaining: int:
	get:
		return _run_manager.hands_remaining

var rerolls_remaining: int:
	get:
		return _run_manager.rerolls_remaining

var round_score_multiplier: float:
	get:
		return _run_manager.round_score_multiplier

var currency: int:
	get:
		return _run_manager.currency

var hand_type_upgrades: Dictionary:
	get:
		return _player_manager.hand_type_upgrades

var shop_item_counts: Dictionary:
	get:
		return _player_manager.shop_item_counts

var owned_trinkets: Array[TrinketData]:
	get:
		return _player_manager.get_owned_trinkets()

var general_modifiers: Dictionary:
	get:
		return _player_manager.general_modifiers

var _player_manager: GameStatePlayerManager = GameStatePlayerManager.new()
var _run_manager: GameStateRunManager = GameStateRunManager.new()
var _locked_shop_offers: Array[Dictionary] = []

func _ready() -> void:
	start_new_run()

func start_new_run() -> void:
	_run_manager.reset_run()
	_player_manager.clear_hand_type_upgrades()
	_player_manager.clear_shop_items()
	_player_manager.reset_general_modifiers()
	clear_locked_shop_offers()
	initialize_player_hand(BASE_DICE_PER_HAND, BASE_DIE_FACE_COUNT)
	currency_changed.emit(currency)
	general_modifiers_changed.emit(get_general_modifiers())
	hand_type_upgrades_changed.emit(get_hand_type_upgrades())
	run_started.emit(round_index)
	start_round(round_index)

func start_next_round() -> void:
	if not _run_manager.advance_to_next_round():
		return
	start_round(round_index)

func start_round(target_round: int) -> void:
	var round_state := _run_manager.start_round(target_round, get_general_modifiers())
	var base_marbles := get_base_marbles_per_round()
	if base_marbles > 0:
		_run_manager.add_currency(base_marbles)
		currency_changed.emit(currency)
		round_state = get_round_state()
	round_started.emit(
		target_round,
		int(round_state.get("quota_remaining", 0)),
		int(round_state.get("hands_remaining", 0)),
		int(round_state.get("rerolls_remaining", 0))
	)
	_emit_round_state()

func add_currency(amount: int) -> void:
	if not _run_manager.add_currency(amount):
		return
	currency_changed.emit(currency)

func spend_currency(amount: int) -> bool:
	var spent := _run_manager.spend_currency(amount)
	if spent:
		currency_changed.emit(currency)
	return spent

func initialize_player_hand(dice_count: int = BASE_DICE_PER_HAND, face_count: int = BASE_DIE_FACE_COUNT) -> void:
	_player_manager.initialize_player_hand(dice_count, face_count)
	player_hand_changed.emit(get_player_hand())

func get_player_hand() -> Array[Dictionary]:
	return _player_manager.get_player_hand()

func set_die_face_value(die_index: int, face_index: int, new_value: int) -> bool:
	var updated := _player_manager.set_die_face_value(die_index, face_index, new_value)
	if updated:
		player_hand_changed.emit(get_player_hand())
	return updated

func set_die_material(die_index: int, material: String) -> bool:
	var updated := _player_manager.set_die_material(die_index, material)
	if updated:
		player_hand_changed.emit(get_player_hand())
	return updated

func get_currency_bonus_for_hand_play() -> int:
	return _player_manager.get_currency_bonus_for_hand_play()

func add_next_round_hands_bonus(amount: int) -> void:
	_run_manager.add_next_round_hands_bonus(amount)

func add_next_round_rerolls_bonus(amount: int) -> void:
	_run_manager.add_next_round_rerolls_bonus(amount)

func add_next_round_quota_reduction(amount: int) -> void:
	_run_manager.add_next_round_quota_reduction(amount)

func add_next_round_score_multiplier_bonus(amount: float) -> void:
	_run_manager.add_next_round_score_multiplier_bonus(amount)

func add_hand_type_upgrade(hand_type: int, base_bonus: int, mult_bonus: int) -> void:
	_player_manager.add_hand_type_upgrade(hand_type, base_bonus, mult_bonus)
	hand_type_upgrades_changed.emit(get_hand_type_upgrades())

func get_hand_type_upgrade(hand_type: int) -> Dictionary:
	return _player_manager.get_hand_type_upgrade(hand_type)

func get_hand_type_upgrades() -> Dictionary:
	return _player_manager.hand_type_upgrades.duplicate(true)

func add_shop_item(item_id: String) -> void:
	_player_manager.add_shop_item(item_id)

func add_owned_trinket(trinket: TrinketData) -> void:
	_player_manager.add_owned_trinket(trinket)

func get_owned_trinkets() -> Array[TrinketData]:
	return _player_manager.get_owned_trinkets()

func get_shop_item_counts() -> Dictionary:
	return _player_manager.get_shop_item_counts()

func add_general_modifiers(modifier_changes: Dictionary) -> Dictionary:
	var modifiers := _player_manager.add_general_modifiers(modifier_changes)
	general_modifiers_changed.emit(modifiers)
	return modifiers

func get_general_modifiers() -> Dictionary:
	return _player_manager.get_general_modifiers()

func get_mapped_face_value(face_value: int) -> int:
	var safe_face_value := maxi(face_value, 1)
	var mapped_key := "face_%d_to" % safe_face_value
	return int(get_general_modifiers().get(mapped_key, safe_face_value))

func get_base_marbles_per_round() -> int:
	return int(get_general_modifiers().get("base_marbles_per_round", 0))

func consume_reroll() -> bool:
	if not _run_manager.consume_reroll():
		return false
	_emit_round_state()
	return true

func add_current_round_rerolls(amount: int) -> void:
	if not _run_manager.add_current_round_rerolls(amount):
		return
	_emit_round_state()

func process_played_hand(score: int) -> void:
	var result := _run_manager.process_played_hand(score)
	_emit_round_state()

	if bool(result.get("round_cleared", false)):
		add_currency(int(result.get("round_reward", 0)))
		if bool(result.get("run_won", false)):
			run_won.emit(round_index, get_run_stats())
			return
		round_completed.emit(round_index)
		reward_phase_started.emit()
		return

	if bool(result.get("run_failed", false)):
		run_failed.emit(round_index)

func consume_hand() -> void:
	process_played_hand(0)

func is_round_complete() -> bool:
	return _run_manager.is_round_complete()

func can_continue_round() -> bool:
	return _run_manager.can_continue_round()

func get_round_state() -> Dictionary:
	return _run_manager.get_round_state()

func _emit_round_state() -> void:
	round_state_changed.emit(get_round_state())

func get_run_stats() -> Dictionary:
	return _run_manager.get_run_stats()

func set_locked_shop_offers(offers: Array[Dictionary]) -> void:
	_locked_shop_offers = offers.duplicate(true)

func get_locked_shop_offers() -> Array[Dictionary]:
	return _locked_shop_offers.duplicate(true)

func clear_locked_shop_offers() -> void:
	_locked_shop_offers.clear()
