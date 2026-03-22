extends Node
class_name ScoreBarScoreController

@export var score_manager: ScoreManager

func _ready() -> void:
	_ensure_score_manager()

func _ensure_score_manager() -> void:
	if score_manager != null:
		return
	score_manager = ScoreManager.new()
	add_child(score_manager)

func set_scoring_context(context: HandScoringContext) -> void:
	_ensure_score_manager()
	score_manager.set_scoring_context(context)

func preview_hand(hand_data: DiceHand) -> Dictionary:
	if hand_data == null:
		return {}
	_ensure_score_manager()
	score_manager.preview_hand(hand_data.to_array())
	return score_manager.get_last_breakdown()

func can_play_previewed_hand() -> bool:
	return score_manager != null and score_manager.can_play_hand()

func get_last_breakdown() -> Dictionary:
	if score_manager == null:
		return {}
	return score_manager.get_last_breakdown()

func commit_played_hand() -> Dictionary:
	if score_manager == null or not score_manager.can_play_hand():
		return {
			"played": false,
			"hand_name": "Unknown",
			"applied_score": 0,
		}

	var breakdown := score_manager.get_last_breakdown()
	score_manager.play_hand()
	var played_hand_name := str(breakdown.get("hand_name", "Unknown"))
	var applied_score := score_manager.commit_played_hand()

	return {
		"played": true,
		"hand_name": played_hand_name,
		"applied_score": applied_score,
		"breakdown": breakdown,
	}
