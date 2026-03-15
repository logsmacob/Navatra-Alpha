extends Control

@onready var hand: Node = $MarginContainer/Hand
@onready var score_bar: VBoxContainer = $MarginContainer/ScoreBar
@onready var hand_type_upgrades: Control = $HandTypeUpgrades

var hand_type_upgrade_service: HandTypeUpgradeService

@onready var win_screen: Control = $WinScreen
@onready var win_stats_label: Label = $WinScreen/VBoxContainer/Stats
@onready var win_back_button: Button = $WinScreen/VBoxContainer/BackToTitle

func _ready() -> void:
	hand_type_upgrade_service = HandTypeUpgradeService.new()

	hand.played_hand_ready.connect(_on_played_hand_ready)
	GameState.round_started.connect(_on_round_started)
	GameState.round_completed.connect(_on_round_completed)
	GameState.reward_phase_started.connect(_on_reward_phase_started)
	GameState.run_failed.connect(_on_run_failed)
	GameState.run_won.connect(_on_run_won)
	GameState.round_state_changed.connect(_on_round_state_changed)
	GameState.currency_changed.connect(_on_currency_changed)
	EventBus.roll_all_dice_requested.connect(_on_roll_all_dice_requested)
	hand_type_upgrades.upgrade_selected.connect(_on_upgrade_selected)
	win_back_button.pressed.connect(_on_win_back_pressed)
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
	var applied_score := int(play_result.get("applied_score", 0))
	print("Played hand: %s | points=%d" % [play_result.get("hand_name", "Unknown"), applied_score])
	GameState.process_played_hand(applied_score)

	await scene_tree.create_timer(1).timeout
	hand._on_played_hand_finish()

func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	print("Round %d started | quota=%d hands=%d rerolls=%d" % [round_index, quota, hands, rerolls])
	hand_type_upgrades.visible = false
	win_screen.visible = false
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
	get_tree().change_scene_to_file("res://scenes/shop/shop.tscn")

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

func _on_run_won(round_index: int, stats: Dictionary) -> void:
	print("Run won on round %d" % round_index)
	hand_type_upgrades.visible = false
	if hand != null:
		hand.visible = false
	if score_bar != null:
		score_bar.visible = false
	var lines := [
		"Rounds Cleared: %d/%d" % [int(stats.get("rounds_cleared", 0)), int(stats.get("max_round", GameState.MAX_ROUNDS))],
		"Total Score: %d" % int(stats.get("total_score", 0)),
		"Hands Played: %d" % int(stats.get("total_hands_played", 0)),
		"Rerolls Used: %d" % int(stats.get("total_rerolls_used", 0)),
		"Currency Earned: %d" % int(stats.get("currency_earned", 0)),
		"Currency Remaining: %d" % int(stats.get("currency_remaining", 0)),
	]
	win_stats_label.text = "\n".join(lines)
	win_screen.visible = true

func _on_win_back_pressed() -> void:
	if hand != null:
		hand.visible = true
	if score_bar != null:
		score_bar.visible = true
	win_screen.visible = false
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/title screen/title_screen.tscn")
