extends Node

## Main gameplay controller script: coordinates this part of the game's behavior.
class_name MainGameplayController

var _hand: Hand
var _score_bar: ScoreBar

func setup(hand: Hand, score_bar: ScoreBar) -> void:
	_hand = hand
	_score_bar = score_bar

func handle_played_hand_ready(hand_data: DiceHand) -> void:
	_score_bar.preview_hand(hand_data)
	var scene_tree := get_tree()
	if scene_tree == null:
		_hand._on_played_hand_finish()
		return

	if not _score_bar.can_play_previewed_hand():
		GameState.consume_hand()
		await scene_tree.create_timer(1).timeout
		_hand._on_played_hand_finish()
		return

	var play_result = await _score_bar.play_previewed_hand()
	var applied_score := int(play_result.get("applied_score", 0))
	var material_currency_bonus := _hand.get_scoring_material_currency_bonus()
	if material_currency_bonus > 0:
		GameState.add_currency(material_currency_bonus)
	print(
		"Played hand: %s | points=%d | material_bonus=%d"
		% [play_result.get("hand_name", "Unknown"), applied_score, material_currency_bonus]
	)
	GameState.process_played_hand(applied_score)

	await scene_tree.create_timer(1).timeout
	_hand._on_played_hand_finish()

func refresh_hand_preview() -> void:
	if _hand == null:
		return
	var current_hand: DiceHand = _hand.get_current_hand()
	_score_bar.preview_hand(current_hand)

func handle_roll_all_dice_requested() -> void:
	refresh_hand_preview()
	_score_bar.update_state()
