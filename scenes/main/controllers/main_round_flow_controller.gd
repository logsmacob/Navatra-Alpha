extends Node
class_name MainRoundFlowController

var _hand_type_upgrades: Control
var _hand_type_upgrade_service: HandTypeUpgradeService

func _init() -> void:
	_hand_type_upgrade_service = HandTypeUpgradeService.new()

func setup(hand_type_upgrades: Control) -> void:
	_hand_type_upgrades = hand_type_upgrades

func handle_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	print("Round %d started | quota=%d hands=%d rerolls=%d" % [round_index, quota, hands, rerolls])
	_hand_type_upgrades.visible = false

func handle_round_completed(round_index: int) -> void:
	print("Round %d complete" % round_index)

func handle_reward_phase_started() -> void:
	refresh_upgrade_options()
	_hand_type_upgrades.visible = true

func handle_upgrade_selected(upgrade: HandTypeUpgradeDefinition) -> void:
	_hand_type_upgrade_service.apply_upgrade(upgrade, GameState)
	_hand_type_upgrades.visible = false
	get_tree().change_scene_to_file("res://scenes/shop/shop.tscn")

func handle_upgrade_reroll_requested() -> void:
	refresh_upgrade_options()

func refresh_upgrade_options() -> void:
	var upgrades := _hand_type_upgrade_service.generate_upgrades(4)
	_hand_type_upgrades.show_upgrades(upgrades)
