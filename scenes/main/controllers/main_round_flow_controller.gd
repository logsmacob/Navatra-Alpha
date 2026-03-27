extends Node

## Main round flow controller script: coordinates this part of the game's behavior.
class_name MainRoundFlowController

signal shop_requested

const DEFAULT_BALANCE_CONFIG := preload("res://data/config/balance/hand_upgrade_balance.tres")

@export var balance_config: HandUpgradeBalanceConfig = DEFAULT_BALANCE_CONFIG

var _hand_type_upgrades: HandTypeUpgradesView
var _hand_type_upgrade_service: HandTypeUpgradeService
var _upgrade_rerolls_used: int = 0

func _init() -> void:
	_hand_type_upgrade_service = HandTypeUpgradeService.new()

func _ready() -> void:
	_apply_balance_config()

func setup(hand_type_upgrades: HandTypeUpgradesView) -> void:
	_hand_type_upgrades = hand_type_upgrades

func handle_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	print("Round %d started | quota=%d hands=%d rerolls=%d" % [round_index, quota, hands, rerolls])
	_hand_type_upgrades.visible = false
	_upgrade_rerolls_used = 0

func handle_round_completed(round_index: int) -> void:
	print("Round %d complete" % round_index)

func handle_reward_phase_started() -> void:
	_upgrade_rerolls_used = 0
	refresh_upgrade_options()
	_hand_type_upgrades.visible = true

func handle_upgrade_selected(upgrade: HandTypeUpgradeDefinition) -> void:
	_hand_type_upgrade_service.apply_upgrade(upgrade, GameState)
	_hand_type_upgrades.visible = false
	shop_requested.emit()

func handle_upgrade_reroll_requested() -> void:
	var reroll_cost := _get_upgrade_reroll_cost()
	if not GameState.spend_currency(reroll_cost):
		_refresh_reroll_price()
		return
	_upgrade_rerolls_used += 1
	refresh_upgrade_options()

func refresh_upgrade_options() -> void:
	var option_count := balance_config.options_per_roll if balance_config != null else 4
	var upgrades := _hand_type_upgrade_service.generate_upgrades(option_count)
	_hand_type_upgrades.show_upgrades(upgrades)
	_refresh_reroll_price()

func _refresh_reroll_price() -> void:
	var reroll_cost := _get_upgrade_reroll_cost()
	_hand_type_upgrades.set_reroll_price(reroll_cost, GameState.currency >= reroll_cost)

func _get_upgrade_reroll_cost() -> int:
	if balance_config == null:
		return 1 + _upgrade_rerolls_used
	return balance_config.reroll_base_cost + (_upgrade_rerolls_used * balance_config.reroll_cost_increase_per_use)

func _apply_balance_config() -> void:
	if balance_config == null:
		return
	_hand_type_upgrade_service.set_rarity_bonuses(balance_config.get_rarity_bonuses())
	_hand_type_upgrade_service.set_rarity_roll_weights(balance_config.get_normalized_rarity_roll_weights())
