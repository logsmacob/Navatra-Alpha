extends Node

# NOTE: Handles die-specific player input.
var model: DieModel

func bind(die_model: DieModel) -> void:
	model = die_model

func _ready() -> void:
	$Button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# NOTE: Direct die roll for now. In future this should route through
	# turn-state checks to prevent rolling at invalid times.
	if model == null:
		return
	DiceRollService.roll_die(model)
