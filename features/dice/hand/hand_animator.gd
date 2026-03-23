extends Node

## Hand animator script: coordinates this part of the game's behavior.
class_name HandAnimator

const SCORE_STEP_DURATION_SECONDS := 0.5
const BASE_STEP_MODULATE := Color("8be9ff")
const MULT_STEP_MODULATE := Color("ff5cf0")
const DEFAULT_STEP_MODULATE := Color(1, 1, 1, 1)
const MODULATE_TWEEN_DURATION_SECONDS := 0.15

@onready var hand = $".."

signal play_animation_finished
signal hand_reset_ready

var is_roll_finished: bool = true

func roll_hand():
	is_roll_finished = false
	var duration :float = .5
	for die: DieUI in hand.dice:
		if !die.is_selected:
			die.roll_if_not_selected(duration)
			duration += .25
	await get_tree().create_timer(duration + .5).timeout
	is_roll_finished = true

func play_hand(target_dice: Array[DieUI]) -> void:
	var tweens: Array[Tween] = []
	for die: DieUI in target_dice:
		var tween := create_tween()
		tween.tween_property(die, "position:y", -die.size.y * 2.15, 0.2)
		tweens.append(tween)

	for tween in tweens:
		await tween.finished

	play_animation_finished.emit()


func animate_played_dice_score_colors(target_dice: Array[DieUI]) -> void:
	if target_dice.is_empty():
		return
	await get_tree().create_timer(SCORE_STEP_DURATION_SECONDS).timeout
	_tween_dice_modulate(target_dice, BASE_STEP_MODULATE)
	await get_tree().create_timer(SCORE_STEP_DURATION_SECONDS).timeout
	_tween_dice_modulate(target_dice, MULT_STEP_MODULATE)
	await get_tree().create_timer(SCORE_STEP_DURATION_SECONDS).timeout
	_tween_dice_modulate(target_dice, BASE_STEP_MODULATE)
	await get_tree().create_timer(SCORE_STEP_DURATION_SECONDS).timeout
	_tween_dice_modulate(target_dice, DEFAULT_STEP_MODULATE)

func _tween_dice_modulate(target_dice: Array[DieUI], color: Color) -> void:
	for die in target_dice:
		if die == null:
			continue
		var tween := create_tween()
		tween.tween_property(die, "modulate", color, MODULATE_TWEEN_DURATION_SECONDS)

func _on_hand_played_hand_finished() -> void:
	var tweens: Array[Tween] = []
	for die: DieUI in hand.dice:
		var tween := create_tween()
		tween.tween_property(die, "position:y", 0, 0.2)
		tweens.append(tween)
	for tween in tweens:
		await tween.finished
	hand_reset_ready.emit()
