extends Node

# NOTE: Handles die-specific player input.
var model: DieModel

func bind(die_model: DieModel) -> void:
	model = die_model

func _ready() -> void:
	$HoldButton.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if model == null:
		return
	model.toggle_hold()
