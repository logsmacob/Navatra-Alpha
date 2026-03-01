extends Control

func _ready() -> void:
	# NOTE: Listen globally for evaluation results.
	if EventBus.dice_evaluated.is_connected(show_result) == false:
		EventBus.dice_evaluated.connect(show_result)

func show_result(result: HandResult) -> void:
	# NOTE: Include note for debugging and future score breakdown UI.
	$Label.text = "Type: %s | %s" % [str(result.type), result.note]

	for index in result.scoring_indices:
		# NOTE: Hook for die highlight animations in the HUD layer.
		# highlight_die(index)
		pass
