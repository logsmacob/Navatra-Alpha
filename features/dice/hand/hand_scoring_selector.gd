extends Node

## Hand scoring selector script: coordinates this part of the game's behavior.
class_name HandScoringSelector

var hand_evaluator := HandEvaluatorService.new()

func get_scoring_dice(dice: Array[DieUI]) -> Array[DieUI]:
	if dice.is_empty():
		return []

	var values: Array[int] = []
	for die: DieUI in dice:
		if die.die == null or die.die.current_face == null:
			continue
		values.append(GameState.get_mapped_face_value(die.die.current_face.value))

	if values.size() != dice.size():
		return dice.duplicate()

	var details := hand_evaluator.get_hand_details(values)
	if details == null or details.groups.is_empty():
		return dice.duplicate()

	var counts_needed := _get_counts_needed(details)
	if counts_needed.is_empty():
		return dice.duplicate()

	var scoring_dice: Array[DieUI] = []
	for die: DieUI in dice:
		if die.die == null or die.die.current_face == null:
			continue
		var value := GameState.get_mapped_face_value(die.die.current_face.value)
		var remaining := int(counts_needed.get(value, 0))
		if remaining > 0:
			scoring_dice.append(die)
			counts_needed[value] = remaining - 1

	if scoring_dice.is_empty():
		return dice.duplicate()

	return scoring_dice

func build_dice_hand(dice: Array[DieUI]) -> DiceHand:
	var values: Array[int] = []
	for die_ui in dice:
		if die_ui.die != null and die_ui.die.current_face != null:
			values.append(GameState.get_mapped_face_value(die_ui.die.current_face.value))
	return DiceHand.new(values)

func _get_counts_needed(details: HandDetails) -> Dictionary:
	var counts_needed := {}
	for group_data in details.groups:
		for group_name in group_data.keys():
			var group_values: Array = group_data[group_name]
			for value in group_values:
				counts_needed[value] = int(counts_needed.get(value, 0)) + 1
	return counts_needed


func get_hand_type_name(dice: Array[DieUI]) -> String:
	var hand := build_dice_hand(dice)
	var hand_type := hand_evaluator.evaluate_hand(hand.to_array())
	return HandEvaluatorService.HandType.keys()[hand_type]
