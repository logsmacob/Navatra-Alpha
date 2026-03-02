extends Node

signal hand_populated

@export var die_scene : PackedScene
@export var dice_container : HBoxContainer

var hand_amount : int = 5
var hand_model := HandModel.new()

func _ready() -> void:
	hand_model.die_added.connect(_on_die_added)
	for i in hand_amount:
		var die_model := DieModel.new()
		hand_model.add_die(die_model)
	hand_populated.emit()

func _on_die_added(die_model: DieModel, index: int):
	var die_view = die_scene.instantiate()
	dice_container.add_child(die_view)
	dice_container.move_child(die_view, index)
	die_view.model = die_model
