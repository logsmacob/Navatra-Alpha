extends Node

@export var die_visuals: Node
@export var select_button: Button

var model := DieModel.new()

func _ready():
	select_button.pressed.connect(_on_select_pressed)
	model.rolled.connect(_on_dice_rolled)
	model.die_selected.connect(_on_is_selected)

func _on_select_pressed():
	model.select()

func _on_dice_rolled(value: int):
	die_visuals.show_value(value)

func _on_is_selected(is_selected: bool):
	die_visuals.show_selected(is_selected)
