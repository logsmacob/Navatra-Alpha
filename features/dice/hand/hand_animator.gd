extends Node
class_name HandAnimator

@onready var hand = $".."

signal play_animation_finished
signal hand_reset_ready

func _on_hand_setup_complete() -> void:
	#any logic that is needed after hand is made
	pass

func play_hand(target_dice: Array[DieUI]) -> void:
	var tweens: Array[Tween] = []
	for die: DieUI in target_dice:
		var tween := create_tween()
		tween.tween_property(die, "position:y", -200, 0.2)
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
