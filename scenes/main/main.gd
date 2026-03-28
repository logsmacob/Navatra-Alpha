extends Control
## Main script: coordinates this part of the game's behavior.

const DEFAULT_SHOP_SCENE := preload("res://scenes/shop/shop.tscn")
const DEFAULT_TITLE_SCENE := preload("res://scenes/title screen/title_screen.tscn")
const SHOP_SCENE_PATH := "res://scenes/shop/shop.tscn"
const TITLE_SCENE_PATH := "res://scenes/title screen/title_screen.tscn"

@export var shop_scene: PackedScene = DEFAULT_SHOP_SCENE
@export var title_scene: PackedScene = DEFAULT_TITLE_SCENE

@onready var hand: Hand = $MarginContainer/Hand
@onready var score_bar: ScoreBar = $MarginContainer/ScoreBar
@onready var hand_type_upgrades: HandTypeUpgradesView = $HandTypeUpgrades

@onready var win_screen: Control = $WinScreen
@onready var win_stats_label: Label = $WinScreen/CenterContainer/VBoxContainer/Stats
@onready var win_back_button: Button = $WinScreen/CenterContainer/VBoxContainer/BackToTitle

@onready var lose_screen: Control = $LoseScreen
@onready var lose_stats_label: Label = $LoseScreen/CenterContainer/VBoxContainer/Stats
@onready var lose_back_button: Button = $LoseScreen/CenterContainer/VBoxContainer/BackToTitle

@onready var gameplay_controller: MainGameplayController = $Controllers/GameplayController
@onready var round_flow_controller: MainRoundFlowController = $Controllers/RoundFlowController
@onready var run_end_controller: MainRunEndController = $Controllers/RunEndController

## Wires the main-scene event graph.
## Event flow overview:
## - Hand local signals drive gameplay preview/resolution.
## - GameState signals drive round/run UI transitions.
## - EventBus handles the shared "reroll finished" refresh broadcast.
func _ready() -> void:
	gameplay_controller.setup(hand, score_bar)
	round_flow_controller.setup(hand_type_upgrades)
	run_end_controller.setup(hand, score_bar, hand_type_upgrades, win_screen, win_stats_label, lose_screen, lose_stats_label)

	# Hand -> gameplay/score-bar flow.
	hand.played_hand_ready.connect(gameplay_controller.handle_played_hand_ready)
	hand.roll_requested.connect(gameplay_controller.handle_roll_requested)
	hand.roll_completed.connect(gameplay_controller.handle_roll_completed)
	hand.play_reset_started.connect(gameplay_controller.handle_play_reset_started)
	hand.reset_roll_finished.connect(gameplay_controller.handle_reset_roll_finished)
	hand.play_hold_started.connect(score_bar.show_preview_math)
	hand.play_hold_ended.connect(score_bar.hide_preview_math)

	# GameState -> screen flow.
	GameState.round_started.connect(_on_round_started)
	GameState.round_completed.connect(round_flow_controller.handle_round_completed)
	GameState.reward_phase_started.connect(round_flow_controller.handle_reward_phase_started)
	GameState.run_failed.connect(run_end_controller.handle_run_failed)
	GameState.run_won.connect(run_end_controller.handle_run_won)

	# Cross-feature events.
	hand_type_upgrades.upgrade_selected.connect(round_flow_controller.handle_upgrade_selected)
	hand_type_upgrades.reroll_requested.connect(round_flow_controller.handle_upgrade_reroll_requested)
	win_back_button.pressed.connect(run_end_controller.handle_back_to_title_pressed)
	lose_back_button.pressed.connect(run_end_controller.handle_back_to_title_pressed)
	round_flow_controller.shop_requested.connect(_on_shop_requested)
	run_end_controller.title_requested.connect(_on_title_requested)

	gameplay_controller.refresh_hand_preview()
	score_bar.update_state()

## Applies round-start UI updates after [GameState] emits [signal round_started].
func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	round_flow_controller.handle_round_started(round_index, quota, hands, rerolls)
	win_screen.visible = false
	lose_screen.visible = false
	gameplay_controller.refresh_hand_preview()
	score_bar.update_state()

func _on_shop_requested() -> void:
	var scene_tree := get_tree()
	if scene_tree == null:
		return
	var target_scene := _resolve_scene(shop_scene, DEFAULT_SHOP_SCENE, SHOP_SCENE_PATH)
	if target_scene == null:
		push_warning("Main: shop_scene is not assigned or invalid.")
		return
	scene_tree.change_scene_to_packed(target_scene)

func _on_title_requested() -> void:
	GameState.start_new_run()
	var scene_tree := get_tree()
	if scene_tree == null:
		return
	var target_scene := _resolve_scene(title_scene, DEFAULT_TITLE_SCENE, TITLE_SCENE_PATH)
	if target_scene == null:
		push_warning("Main: title_scene is not assigned or invalid.")
		return
	scene_tree.change_scene_to_packed(target_scene)

func _resolve_scene(primary_scene: PackedScene, fallback_scene: PackedScene, fallback_path: String) -> PackedScene:
	if primary_scene != null and primary_scene.can_instantiate():
		return primary_scene
	if fallback_scene != null and fallback_scene.can_instantiate():
		return fallback_scene
	var loaded_scene := load(fallback_path) as PackedScene
	if loaded_scene != null and loaded_scene.can_instantiate():
		return loaded_scene
	return null
