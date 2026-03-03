extends Control

@onready var hand = $HBoxContainer
@export var die_ui_scene: PackedScene

var dice : Array[DieUI] = []


func _ready() -> void:
	for i in range(5):
		var die_ui : DieUI = die_ui_scene.instantiate()
		hand.add_child(die_ui)

		die_ui.set_die(DieInstance.create_standard_d6())
		die_ui.roll_if_not_selected()

		dice.append(die_ui)


func _on_button_pressed() -> void:
	for die in dice:
		die.roll_if_not_selected()
