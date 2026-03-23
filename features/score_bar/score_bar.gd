extends Control
## Score bar script: coordinates this part of the game's behavior.
class_name ScoreBar

@export var meta_controller: ScoreBarMetaController
@export var math_controller: ScoreBarMathController
@export var score_controller: ScoreBarScoreController

var _last_hands_remaining: int = 0

func _ready() -> void:
	GameState.round_started.connect(_on_round_started)
	GameState.round_state_changed.connect(_on_round_state_changed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)

	math_controller.reset_display()
	update_state(GameState.get_round_state())

func set_scoring_context(context: HandScoringContext) -> void:
	if score_controller == null:
		return
	score_controller.set_scoring_context(context)

func preview_hand(hand_data: DiceHand) -> void:
	if hand_data == null or score_controller == null:
		return

	set_scoring_context(_build_scoring_context())
	var breakdown := score_controller.preview_hand(hand_data)
	math_controller.update_preview(breakdown)

func can_play_previewed_hand() -> bool:
	return score_controller != null and score_controller.can_play_previewed_hand()

func play_previewed_hand() -> Dictionary:
	if score_controller == null or not score_controller.can_play_previewed_hand():
		return {
			"played": false,
			"hand_name": "Unknown",
			"applied_score": 0,
		}

	var breakdown := score_controller.get_last_breakdown()
	await math_controller.animate_played_hand(get_tree(), breakdown)
	return score_controller.commit_played_hand()

func animate_quota_update(applied_score: int) -> void:
	if math_controller == null:
		return
	await math_controller.animate_quota_update(get_tree(), GameState.quota_remaining - applied_score)

func update_state(state: Dictionary = {}) -> void:
	if state.is_empty():
		state = GameState.get_round_state()
	meta_controller.update_state(state, GameState.get_general_modifiers())

func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	_last_hands_remaining = hands
	update_state({
		"round_index": round_index,
		"quota_remaining": quota,
		"hands_remaining": hands,
		"rerolls_remaining": rerolls,
		"currency": GameState.currency,
	})

func _on_round_state_changed(state: Dictionary) -> void:
	_last_hands_remaining = int(state.get("hands_remaining", _last_hands_remaining))
	update_state(state)

func _on_currency_changed(_amount: int) -> void:
	update_state()

func _on_general_modifiers_changed(_modifiers: Dictionary) -> void:
	update_state()

func zero_math_display() -> void:
	math_controller.zero_math_display()

func clear_after_play_reset() -> void:
	math_controller.clear_after_play_reset()

func show_preview_math() -> void:
	math_controller.show_preview_math()

func hide_preview_math() -> void:
	math_controller.hide_preview_math()

func _build_scoring_context() -> HandScoringContext:
	return HandScoringContext.new(GameState.hand_type_upgrades, GameState.round_score_multiplier)
