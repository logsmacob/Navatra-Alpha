extends Control

@onready var hand: Node = $MarginContainer/Hand
@onready var score_bar: VBoxContainer = $MarginContainer/ScoreBar
@onready var hand_type_upgrades: Control = $HandTypeUpgrades

var hand_type_upgrade_service: HandTypeUpgradeService

func _ready() -> void:
	hand_type_upgrade_service = HandTypeUpgradeService.new()

	hand.played_hand_ready.connect(_on_played_hand_ready)
	GameState.round_started.connect(_on_round_started)
	GameState.round_completed.connect(_on_round_completed)
	GameState.reward_phase_started.connect(_on_reward_phase_started)
	GameState.run_failed.connect(_on_run_failed)
	GameState.round_state_changed.connect(_on_round_state_changed)
	GameState.currency_changed.connect(_on_currency_changed)
	EventBus.roll_all_dice_requested.connect(_on_roll_all_dice_requested)
	hand_type_upgrades.upgrade_selected.connect(_on_upgrade_selected)
	hand_type_upgrades.reroll_requested.connect(_on_upgrade_reroll_requested)

	_refresh_hand_preview()
	score_bar.update_state()

func _on_played_hand_ready(hand_data: DiceHand) -> void:
	score_bar.preview_hand(hand_data)
	var scene_tree := get_tree()
	if scene_tree == null:
		hand._on_played_hand_finish()
		return

	if not score_bar.can_play_previewed_hand():
		GameState.consume_hand()
		await scene_tree.create_timer(1).timeout
		hand._on_played_hand_finish()
		return

	var play_result = score_bar.play_previewed_hand()
	print("Played hand: %s | points=%d" % [play_result.get("hand_name", "Unknown"), int(play_result.get("applied_score", 0))])
	GameState.apply_score_to_quota(int(play_result.get("applied_score", 0)))
	var hand_currency_bonus := 1 + GameState.get_currency_bonus_for_hand_play()
	GameState.add_currency(hand_currency_bonus)
	GameState.consume_hand()

	await scene_tree.create_timer(1).timeout
	hand._on_played_hand_finish()

func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	print("Round %d started | quota=%d hands=%d rerolls=%d" % [round_index, quota, hands, rerolls])
	hand_type_upgrades.visible = false
	_refresh_hand_preview()
	score_bar.update_state()

func _on_round_completed(round_index: int) -> void:
	print("Round %d complete" % round_index)

func _on_reward_phase_started() -> void:
	_refresh_upgrade_options()
	hand_type_upgrades.visible = true

func _on_upgrade_selected(upgrade: HandTypeUpgradeDefinition) -> void:
	hand_type_upgrade_service.apply_upgrade(upgrade, GameState)
	hand_type_upgrades.visible = false
	get_tree().change_scene_to_file("res://scenes/shop.tscn")

func _on_upgrade_reroll_requested() -> void:
	_refresh_upgrade_options()

func _on_run_failed(round_index: int) -> void:
	print("Run failed on round %d" % round_index)
	hand_type_upgrades.visible = false
	GameState.start_new_run()

func _on_round_state_changed(state: Dictionary) -> void:
	print("State: ", state)
	score_bar.update_state(state)

func _on_roll_all_dice_requested() -> void:
	_refresh_hand_preview()
	score_bar.update_state()

func _refresh_hand_preview() -> void:
	if hand == null:
		return

	if not hand.has_method("get_current_hand"):
		return

	var current_hand: DiceHand = hand.call("get_current_hand")
	score_bar.preview_hand(current_hand)

func _refresh_upgrade_options() -> void:
	var upgrades := hand_type_upgrade_service.generate_upgrades(4)
	hand_type_upgrades.show_upgrades(upgrades)

func _on_currency_changed(_amount: int) -> void:
	score_bar.update_state()
