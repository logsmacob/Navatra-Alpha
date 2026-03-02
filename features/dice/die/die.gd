extends Control

@onready var die_controller = $DieController

var model: DieModel = DieModel.new():
	set(value):
		model = value
		if is_node_ready():
			die_controller.model = model

func _ready() -> void:
	die_controller.model = model
	
