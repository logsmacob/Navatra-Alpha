class_name ChanceTrinketData
extends TrinketData

@export_group("Chance Variant")
@export_range(0.0, 100.0, 0.1) var activation_chance_percent: float = 100.0
@export var use_hand_type_condition: bool = true
@export var required_hand_type: HandEvaluatorService.HandType = HandEvaluatorService.HandType.HIGH_DIE
@export var use_face_condition: bool = false
@export_range(1, 6, 1) var required_face_value: int = 1

func get_trigger_summary() -> String:
	var chance_text := "%s%%" % str(snappedf(activation_chance_percent, 0.1))
	if use_hand_type_condition and use_face_condition:
		return "%s on %s with face [%d]" % [chance_text, HandEvaluatorService.HandType.keys()[required_hand_type], required_face_value]
	if use_hand_type_condition:
		return "%s on %s" % [chance_text, HandEvaluatorService.HandType.keys()[required_hand_type]]
	if use_face_condition:
		return "%s on face [%d]" % [chance_text, required_face_value]
	return "%s each played hand" % chance_text

func get_runtime_scoring_bonus(play_context: Dictionary) -> Dictionary:
	if not _matches_context(play_context):
		return {"base": 0, "mult": 0, "currency": 0}
	if not _roll_activation_chance():
		return {"base": 0, "mult": 0, "currency": 0}
	return {"base": base, "mult": mult, "currency": 0}

func _matches_context(play_context: Dictionary) -> bool:
	if use_hand_type_condition:
		var context_hand_type := int(play_context.get("hand_type", HandEvaluatorService.HandType.HIGH_DIE))
		if context_hand_type != int(required_hand_type):
			return false
	if use_face_condition:
		var scoring_face_values: Array = play_context.get("scoring_face_values", [])
		if not scoring_face_values.has(required_face_value):
			return false
	return true

func _roll_activation_chance() -> bool:
	if activation_chance_percent >= 100.0:
		return true
	if activation_chance_percent <= 0.0:
		return false
	return randf() <= (activation_chance_percent / 100.0)
