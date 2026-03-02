extends Control

@onready var die_controller = $DieController

var model = DieModel.new()

func _ready() -> void:
	model = die_controller.model
	
