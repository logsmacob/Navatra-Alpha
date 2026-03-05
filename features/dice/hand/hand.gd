extends Control

@onready var hand_container = $HBoxContainer/Panel/HandContainer
@export var die_ui_scene: PackedScene

signal setup_complete
signal played_hand_ready(dice : Array[DieUI])
signal played_hand_finished

var dice : Array[DieUI] = []

func _ready() -> void:
	for i in range(5):
		var die_ui : DieUI = die_ui_scene.instantiate()
		hand_container.add_child(die_ui)

		die_ui.set_die(DieInstance.create_standard_d6())
		die_ui.roll_if_not_selected()

		dice.append(die_ui)
	setup_complete.emit()

func _on_roll_pressed() -> void:
	for die in dice:
		die.roll_if_not_selected()

func _on_hand_animator_play_animation_finished() -> void:
	played_hand_ready.emit(dice)

func _on_played_hand_finish():
	played_hand_finished.emit()
