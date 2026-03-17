extends Node

## Hand animator script: coordinates this part of the game's behavior.
class_name HandAnimator

@onready var hand = $".."

signal play_animation_finished
signal hand_reset_ready

var is_roll_finished: bool = true

func roll_hand():
	is_roll_finished = false
	var duration :float = .5
	for die: DieUI in hand.dice:
		die.roll_if_not_selected(duration)
		duration += .5
	await get_tree().create_timer(duration + .5).timeout
	is_roll_finished = true

func play_hand(target_dice: Array[DieUI]) -> void:
	var tweens: Array[Tween] = []
	for die: DieUI in target_dice:
		var tween := create_tween()
		tween.tween_property(die, "position:y", -die.size.y * 2, 0.2)
		tweens.append(tween)

	for tween in tweens:
		await tween.finished

	play_animation_finished.emit()

func _on_hand_played_hand_finished() -> void:
	var tweens: Array[Tween] = []
	for die: DieUI in hand.dice:
		var tween := create_tween()
		tween.tween_property(die, "position:y", 0, 0.2)
		tweens.append(tween)
	for tween in tweens:
		await tween.finished
	hand_reset_ready.emit()
