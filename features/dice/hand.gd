extends Node

@onready var hand_controller = $HandController
@onready var hand_visuals = $HandVisuals

var hand_model = HandModel

func _ready() -> void:
	hand_controller.hand_populated.connect(_on_hand_populated)

func _on_hand_populated():
	hand_model = hand_controller.hand_model
	for die in hand_model.dice:
		die.roll()
