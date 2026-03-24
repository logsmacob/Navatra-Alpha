extends Node

## Main gameplay controller script: coordinates this part of the game's behavior.
class_name MainGameplayController

var _hand: Hand
var _score_bar: ScoreBar

## Stores scene references used during the local main-scene gameplay flow.
func setup(hand: Hand, score_bar: ScoreBar) -> void:
	_hand = hand
	_score_bar = score_bar

## Resolves a played hand after [Hand] finishes its play animation.
## Flow: [Hand.signal played_hand_ready] -> score preview/apply -> [Hand.complete_play_resolution].
## Hidden dependency note: this controller expects [Hand] to own the next animation step.
func handle_played_hand_ready(hand_data: DiceHand) -> void:
	if _hand == null or _score_bar == null:
		return
	_score_bar.zero_math_display()
	_score_bar.preview_hand(hand_data)
	var scene_tree := get_tree()
	if scene_tree == null:
		_hand.complete_play_resolution()
		return

	if not _score_bar.can_play_previewed_hand():
		GameState.consume_hand()
		await scene_tree.create_timer(1).timeout
		_hand.complete_play_resolution()
		return

	_hand.animate_scoring_dice_score_colors()
	var play_result = await _score_bar.play_previewed_hand()
	if not _can_continue_resolution():
		return
	var applied_score := int(play_result.get("applied_score", 0))
	await _score_bar.animate_quota_update(applied_score)
	if not _can_continue_resolution():
		return
	var material_currency_bonus := _hand.get_scoring_material_currency_bonus()
	if material_currency_bonus > 0:
		GameState.add_currency(material_currency_bonus)
	print(
		"Played hand: %s | points=%d | material_bonus=%d"
		% [play_result.get("hand_name", "Unknown"), applied_score, material_currency_bonus]
	)
	GameState.process_played_hand(applied_score)

	await scene_tree.create_timer(1).timeout
	if not _can_continue_resolution():
		return
	_hand.complete_play_resolution()

func _can_continue_resolution() -> bool:
	return is_instance_valid(_hand) and is_instance_valid(_score_bar) and is_inside_tree()

## Attempts to consume a reroll and trigger the hand-roll flow.
func handle_roll_requested() -> void:
	if _hand == null:
		return
	if GameState.consume_reroll():
		_hand.roll_hand()

## Rebuilds the preview math from the currently visible dice.
func refresh_hand_preview() -> void:
	if _hand == null:
		return
	var current_hand: DiceHand = _hand.get_current_hand()
	_score_bar.preview_hand(current_hand)

## Handles local reroll-refresh event emitted after [Hand.roll_hand].
## Special case: during post-play reset we still refresh preview data so the main hand label
## stays in sync with newly rolled dice while math columns remain hidden until reset completes.
func handle_roll_completed() -> void:
	refresh_hand_preview()
	if _score_bar == null:
		return
	_score_bar.update_state()

## Clears the played-hand math columns as soon as the post-play reset phase begins.
func handle_play_reset_started() -> void:
	if _score_bar == null:
		return
	_score_bar.zero_math_display()

## Clears score-bar preview state after the reset roll completes.
func handle_reset_roll_finished() -> void:
	if _score_bar == null:
		return
	_score_bar.clear_after_play_reset()
