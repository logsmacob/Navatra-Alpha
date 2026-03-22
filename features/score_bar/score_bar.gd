extends Control
## Score bar script: coordinates this part of the game's behavior.
class_name ScoreBar

@export var round_index_label: Label
@export var marble_label: Label
@export var current_hand_points_label: Label
@export var hand_type_label: Label
@export var current_hand_points_label_math: Label
@export var general_modifiers_label: Label
@export var Base: Label
@export var Mult: Label
@export var Result: Label
@export var Quota: Label

var _meta_controller: ScoreBarMetaController
var _math_controller: ScoreBarMathController
var _score_controller: ScoreBarScoreController
var _last_hands_remaining: int = 0

func _ready() -> void:
	_meta_controller = ScoreBarMetaController.new()
	add_child(_meta_controller)
	_meta_controller.setup(round_index_label, marble_label, Quota, general_modifiers_label)

	_math_controller = ScoreBarMathController.new()
	add_child(_math_controller)
	_math_controller.setup(
		current_hand_points_label,
		hand_type_label,
		current_hand_points_label_math,
		Base,
		Mult,
		Result
	)

	_score_controller = ScoreBarScoreController.new()
	add_child(_score_controller)

	GameState.round_started.connect(_on_round_started)
	GameState.round_state_changed.connect(_on_round_state_changed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)

	_math_controller.reset_display()
	update_state(GameState.get_round_state())

func set_scoring_context(context: HandScoringContext) -> void:
	if _score_controller == null:
		return
	_score_controller.set_scoring_context(context)

func preview_hand(hand_data: DiceHand) -> void:
	if hand_data == null or _score_controller == null:
		return

	set_scoring_context(_build_scoring_context())
	var breakdown := _score_controller.preview_hand(hand_data)
	_math_controller.update_preview(breakdown)

func can_play_previewed_hand() -> bool:
	return _score_controller != null and _score_controller.can_play_previewed_hand()

func play_previewed_hand() -> Dictionary:
	if _score_controller == null or not _score_controller.can_play_previewed_hand():
		return {
			"played": false,
			"hand_name": "Unknown",
			"applied_score": 0,
		}

	var breakdown := _score_controller.get_last_breakdown()
	await _math_controller.animate_played_hand(get_tree(), breakdown)
	return _score_controller.commit_played_hand()

func update_state(state: Dictionary = {}) -> void:
	if state.is_empty():
		state = GameState.get_round_state()
	_meta_controller.update_state(state, GameState.get_general_modifiers())

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
	var hands_remaining := int(state.get("hands_remaining", _last_hands_remaining))
	if hands_remaining < _last_hands_remaining:
		_math_controller.reset_display()
	_last_hands_remaining = hands_remaining
	update_state(state)

func _on_currency_changed(_amount: int) -> void:
	update_state()

func _on_general_modifiers_changed(_modifiers: Dictionary) -> void:
	update_state()

func zero_math_display() -> void:
	_math_controller.zero_math_display()

func clear_after_play_reset() -> void:
	_math_controller.clear_after_play_reset()

func show_preview_math() -> void:
	_math_controller.show_preview_math()

func hide_preview_math() -> void:
	_math_controller.hide_preview_math()

func _build_scoring_context() -> HandScoringContext:
	return HandScoringContext.new(GameState.hand_type_upgrades, GameState.round_score_multiplier)
