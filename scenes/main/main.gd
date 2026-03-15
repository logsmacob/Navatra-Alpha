extends Control

@onready var hand: Node = $MarginContainer/Hand
@onready var score_bar: VBoxContainer = $MarginContainer/ScoreBar
@onready var hand_type_upgrades: Control = $HandTypeUpgrades

@onready var win_screen: Control = $WinScreen
@onready var win_stats_label: Label = $WinScreen/CenterContainer/VBoxContainer/Stats
@onready var win_back_button: Button = $WinScreen/CenterContainer/VBoxContainer/BackToTitle

@onready var lose_screen: Control = $LoseScreen
@onready var lose_stats_label: Label = $LoseScreen/CenterContainer/VBoxContainer/Stats
@onready var lose_back_button: Button = $LoseScreen/CenterContainer/VBoxContainer/BackToTitle

@onready var gameplay_controller: MainGameplayController = $Controllers/GameplayController
@onready var round_flow_controller: MainRoundFlowController = $Controllers/RoundFlowController
@onready var run_end_controller: MainRunEndController = $Controllers/RunEndController

func _ready() -> void:
	gameplay_controller.setup(hand, score_bar)
	round_flow_controller.setup(hand_type_upgrades)
	run_end_controller.setup(hand, score_bar, hand_type_upgrades, win_screen, win_stats_label, lose_screen, lose_stats_label)

	hand.played_hand_ready.connect(gameplay_controller.handle_played_hand_ready)
	GameState.round_started.connect(_on_round_started)
	GameState.round_completed.connect(round_flow_controller.handle_round_completed)
	GameState.reward_phase_started.connect(round_flow_controller.handle_reward_phase_started)
	GameState.run_failed.connect(run_end_controller.handle_run_failed)
	GameState.run_won.connect(run_end_controller.handle_run_won)
	GameState.round_state_changed.connect(_on_round_state_changed)
	GameState.currency_changed.connect(_on_currency_changed)
	EventBus.roll_all_dice_requested.connect(gameplay_controller.handle_roll_all_dice_requested)
	hand_type_upgrades.upgrade_selected.connect(round_flow_controller.handle_upgrade_selected)
	hand_type_upgrades.reroll_requested.connect(round_flow_controller.handle_upgrade_reroll_requested)
	win_back_button.pressed.connect(run_end_controller.handle_back_to_title_pressed)
	lose_back_button.pressed.connect(run_end_controller.handle_back_to_title_pressed)

	gameplay_controller.refresh_hand_preview()
	score_bar.update_state()

func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	round_flow_controller.handle_round_started(round_index, quota, hands, rerolls)
	win_screen.visible = false
	lose_screen.visible = false
	gameplay_controller.refresh_hand_preview()
	score_bar.update_state()

func _on_round_state_changed(state: Dictionary) -> void:
	print("State: ", state)
	score_bar.update_state(state)

func _on_currency_changed(_amount: int) -> void:
	score_bar.update_state()
