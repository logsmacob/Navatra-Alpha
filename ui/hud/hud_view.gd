extends Control

func _ready() -> void:
	# NOTE: Listen globally for evaluation results.
	if EventBus.dice_evaluated.is_connected(show_result) == false:
		EventBus.dice_evaluated.connect(show_result)
	if EventBus.round_state_changed.is_connected(show_round_state) == false:
		EventBus.round_state_changed.connect(show_round_state)
	if EventBus.hand_scored.is_connected(show_score) == false:
		EventBus.hand_scored.connect(show_score)

func show_result(result: HandResult) -> void:
	# NOTE: Include note for debugging and future score breakdown UI.
	$Label.text = "Type: %s | %s" % [str(result.type), result.note]

	for index in result.scoring_indices:
		# NOTE: Hook for die highlight animations in the HUD layer.
		# highlight_die(index)
		pass

func show_round_state(round_state: RoundStateModel) -> void:
	$Label.text = "Round %d | Quota %d | Hands %d | Rerolls %d" % [
		round_state.round_index,
		round_state.current_quota,
		round_state.hands_remaining,
		round_state.rerolls_remaining
	]

func show_score(score: int, quota_remaining: int) -> void:
	$Label.text = "Scored %d | Quota Left %d" % [score, quota_remaining]
