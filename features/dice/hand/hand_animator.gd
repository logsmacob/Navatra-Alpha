extends Node

@onready var hand = $".."

signal play_animation_finished
signal hand_reset_ready

var hand_evaluator := HandEvaluatorService.new()

func _on_hand_setup_complete() -> void:
	for die : DieUI in hand.dice:
		die.die_selected.connect(_on_die_selected)

func _on_die_selected(die_ui: DieUI):
	if die_ui.is_selected:
		var tween = create_tween()
		tween.tween_property(die_ui, "position:y", -100, 0.2)
	else:
		var tween = create_tween()
		tween.tween_property(die_ui, "position:y", 0, 0.2)

func _on_play_pressed() -> void:
	var tweens: Array[Tween] = []
	var target_dice := _get_scoring_dice()

	for die: DieUI in target_dice:
		var tween = create_tween()
		tween.tween_property(die, "position:y", -200, 0.2)
		tweens.append(tween)

	for tween in tweens:
		await tween.finished

	play_animation_finished.emit()

func _get_scoring_dice() -> Array[DieUI]:
	if hand == null or hand.dice.is_empty():
		return []

	var values: Array[int] = []
	for die: DieUI in hand.dice:
		if die.die == null or die.die.current_face == null:
			continue
		values.append(die.die.current_face.value)

	if values.size() != hand.dice.size():
		return hand.dice.duplicate()

	var details := hand_evaluator.get_hand_details(values)
	if details == null or details.groups.is_empty():
		return hand.dice.duplicate()

	var counts_needed := _get_counts_needed(details)
	if counts_needed.is_empty():
		return hand.dice.duplicate()

	var scoring_dice: Array[DieUI] = []
	for die: DieUI in hand.dice:
		if die.die == null or die.die.current_face == null:
			continue
		var value := die.die.current_face.value
		var remaining := int(counts_needed.get(value, 0))
		if remaining > 0:
			scoring_dice.append(die)
			counts_needed[value] = remaining - 1

	if scoring_dice.is_empty():
		return hand.dice.duplicate()

	return scoring_dice

func _get_counts_needed(details: HandDetails) -> Dictionary:
	var counts_needed := {}
	for group_data in details.groups:
		for group_name in group_data.keys():
			var group_values: Array = group_data[group_name]
			for value in group_values:
				counts_needed[value] = int(counts_needed.get(value, 0)) + 1
	return counts_needed

func _on_hand_played_hand_finished() -> void:
	var tweens: Array[Tween] = []
	for die : DieUI in hand.dice:
		var tween = create_tween()
		tween.tween_property(die, "position:y", 0, 0.2)
		tweens.append(tween)
	for tween in tweens:
		await tween.finished
	hand_reset_ready.emit()
