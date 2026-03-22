extends Control
## Hand script: coordinates this part of the game's behavior.
class_name Hand

@onready var hand_container: Node = $HBoxContainer/Panel/HandContainer
@onready var hand_animator: HandAnimator = $HandAnimator
@onready var hand_scoring_selector: HandScoringSelector = $HandScoringSelector
@onready var hand_dice_pool: HandDicePool = $HandDicePool
@onready var hand_currency_bonus_service: HandCurrencyBonusService = $HandCurrencyBonusService
@onready var hand_button_manager: HandButtonManager = $"Button Manager"

## Packed die scene used by [HandDicePool] to build the visible hand.
@export var die_ui_scene: PackedScene
## Number of dice instantiated for this hand scene.
@export var dice_per_hand: int = 5

## True while the hand can accept roll/play input.
var is_hand_ready: bool = false
## True during the "play resolved -> reset roll" bridge so listeners can skip duplicate updates.
var is_resolving_play_reset: bool = false

## Current visible dice in the hand, delegated to [HandDicePool].
var dice: Array[DieUI]:
	get:
		return hand_dice_pool.get_dice()

## Emitted once local hand setup is complete and child systems can safely initialize.
signal setup_complete
## Emitted after the play animation finishes and scoring data is ready for gameplay resolution.
signal played_hand_ready(hand: DiceHand)
## Emitted when gameplay resolution is done and the hand can start its reset animation.
signal played_hand_finished
## Emitted when the post-play reset phase begins so UI can clear transient played-hand math before rerolling.
signal play_reset_started
## Emitted when the play button has been held long enough to show score preview math.
signal play_hold_started
## Emitted when the play-button hold preview should be dismissed.
signal play_hold_ended
## Emitted after the post-play reset roll finishes and UI can clear preview state.
signal reset_roll_finished

func _ready() -> void:
	update_buttons()
	hand_dice_pool.setup(die_ui_scene, dice_per_hand, hand_container)
	hand_button_manager.play_hold_started.connect(_on_play_hold_started)
	hand_button_manager.play_hold_ended.connect(_on_play_hold_ended)
	setup_complete.emit()
	is_hand_ready = true

## Consumes a reroll and starts the hand roll flow.
## Flow: roll button -> consume reroll -> [method roll_hand] -> EventBus update.
func _on_roll_pressed() -> void:
	if not is_hand_ready:
		return

	if GameState.consume_reroll():
		roll_hand()

## Rolls all non-held dice, waits for animation timing, then broadcasts the refresh event.
## Hidden dependency note: [MainGameplayController] refreshes score preview after [EventBus.roll_all_dice_requested].
func roll_hand() -> void:
	if hand_animator.is_roll_finished:
		is_hand_ready = false
		hand_button_manager.disable_buttons()
		await hand_animator.roll_hand()
		hand_button_manager.enable_buttons()
		is_hand_ready = true
		EventBus.roll_all_dice_requested.emit()
		update_buttons()

## Starts the play flow and emits [signal played_hand_ready] once scoring data is available.
## Flow: play button -> play animation -> [signal played_hand_ready] -> gameplay controller resolves score.
func _on_play_pressed() -> void:
	if not is_hand_ready:
		return
	is_hand_ready = false
	if hand_animator == null:
		push_error("HandAnimator node is missing or has incorrect script.")
		is_hand_ready = true
		return
	hand_button_manager.disable_buttons()
	await hand_animator.play_hand(hand_scoring_selector.get_scoring_dice(dice))
	hand_dice_pool.clear_selection()
	played_hand_ready.emit(hand_scoring_selector.build_dice_hand(dice))

## Returns the hand data currently shown in the UI for preview/evaluation.
func get_current_hand() -> DiceHand:
	return hand_scoring_selector.build_dice_hand(dice)

## Returns the currency bonus granted by the currently scoring dice materials.
func get_scoring_material_currency_bonus() -> int:
	var scoring_dice := hand_scoring_selector.get_scoring_dice(dice)
	return hand_currency_bonus_service.get_scoring_material_currency_bonus(scoring_dice)

## Public bridge used by gameplay orchestration once score resolution is finished.
## This replaces external calls to the private finish handler so the signal chain is easier to follow.
func complete_play_resolution() -> void:
	_on_played_hand_finish()

## Emits the local signal that tells [HandAnimator] to run the reset animation.
func _on_played_hand_finish() -> void:
	played_hand_finished.emit()

## Handles the final step of the play chain after [HandAnimator] finishes resetting the dice.
## Flow: [signal played_hand_finished] -> HandAnimator reset -> [signal hand_reset_ready] -> [signal play_reset_started] -> roll -> [signal reset_roll_finished].
func _on_hand_reset_ready() -> void:
	is_resolving_play_reset = true
	play_reset_started.emit()
	await roll_hand()
	is_resolving_play_reset = false
	reset_roll_finished.emit()

## Refreshes button labels from the latest round state.
func update_buttons() -> void:
	hand_button_manager.update_button_labels()

## Forwards the button-manager hold event so parent scenes can react without reaching into the child node.
func _on_play_hold_started() -> void:
	play_hold_started.emit()

## Forwards the button-manager hold-release event.
func _on_play_hold_ended() -> void:
	play_hold_ended.emit()
