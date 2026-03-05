extends Node

@onready var hand = $".."

signal play_animation_finished

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
	for die : DieUI in hand.dice:
		var tween = create_tween()
		tween.tween_property(die, "position:y", -200, 0.2)
	play_animation_finished.emit()

func _on_hand_played_hand_finished() -> void:
	for die : DieUI in hand.dice:
		var tween = create_tween()
		tween.tween_property(die, "position:y", 0, 0.2)
