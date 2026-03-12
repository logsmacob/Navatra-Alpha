extends Control

@onready var hand: Node = $MarginContainer/Hand
@onready var score_bar: VBoxContainer = $VBoxContainer
@onready var reward_shop: Control = $RewardShop

var reward_service: RewardService

func _ready() -> void:
	reward_service = RewardService.new()

	hand.played_hand_ready.connect(_on_played_hand_ready)
	GameState.round_started.connect(_on_round_started)
	GameState.round_completed.connect(_on_round_completed)
	GameState.reward_phase_started.connect(_on_reward_phase_started)
	GameState.run_failed.connect(_on_run_failed)
	GameState.round_state_changed.connect(_on_round_state_changed)
	EventBus.roll_all_dice_requested.connect(_on_roll_all_dice_requested)
	reward_shop.reward_selected.connect(_on_reward_selected)

	_refresh_hand_preview()
	score_bar.update_state()

func _on_played_hand_ready(hand_data: DiceHand) -> void:
	score_bar.preview_hand(hand_data)

	if not score_bar.can_play_previewed_hand():
		GameState.consume_hand()
		await get_tree().create_timer(1).timeout
		hand._on_played_hand_finish()
		return

	var play_result := score_bar.play_previewed_hand()
	print("Played hand: %s | points=%d" % [play_result.get("hand_name", "Unknown"), int(play_result.get("applied_score", 0))])
	GameState.apply_score_to_quota(int(play_result.get("applied_score", 0)))
	GameState.consume_hand()

	await get_tree().create_timer(1).timeout
	hand._on_played_hand_finish()

func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	print("Round %d started | quota=%d hands=%d rerolls=%d" % [round_index, quota, hands, rerolls])
	reward_shop.visible = false

func _on_round_completed(round_index: int) -> void:
	print("Round %d complete" % round_index)

func _on_reward_phase_started() -> void:
	var rewards := reward_service.generate_rewards(3)
	reward_shop.show_rewards(rewards)

func _on_reward_selected(reward: RewardDefinition) -> void:
	reward_service.apply_reward(reward, GameState)
	reward_shop.visible = false
	GameState.start_next_round()

func _on_run_failed(round_index: int) -> void:
	print("Run failed on round %d" % round_index)
	reward_shop.visible = false
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
