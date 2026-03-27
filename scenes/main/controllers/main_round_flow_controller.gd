extends Node

## Main round flow controller script: coordinates this part of the game's behavior.
class_name MainRoundFlowController

signal shop_requested

const UPGRADE_REROLL_BASE_COST: int = 1

var _hand_type_upgrades: HandTypeUpgradesView
var _hand_type_upgrade_service: HandTypeUpgradeService
var _upgrade_rerolls_used: int = 0

func _init() -> void:
	_hand_type_upgrade_service = HandTypeUpgradeService.new()

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
	var upgrades := _hand_type_upgrade_service.generate_upgrades(4)
	_hand_type_upgrades.show_upgrades(upgrades)
	_refresh_reroll_price()

func _refresh_reroll_price() -> void:
	var reroll_cost := _get_upgrade_reroll_cost()
	_hand_type_upgrades.set_reroll_price(reroll_cost, GameState.currency >= reroll_cost)

func _get_upgrade_reroll_cost() -> int:
	return UPGRADE_REROLL_BASE_COST + _upgrade_rerolls_used
