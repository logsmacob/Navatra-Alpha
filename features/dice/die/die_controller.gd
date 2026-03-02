extends Node

@export var die_visuals: Node
@export var select_button: Button

var model: DieModel = DieModel.new():
	set(value):
		if model == value:
			return
		_disconnect_model_signals(model)
		model = value
		if is_node_ready():
			_connect_model_signals(model)

func _ready():
	select_button.pressed.connect(_on_select_pressed)
	_connect_model_signals(model)

func _connect_model_signals(target_model: DieModel) -> void:
	if !target_model.rolled.is_connected(_on_dice_rolled):
		target_model.rolled.connect(_on_dice_rolled)
	if !target_model.die_selected.is_connected(_on_is_selected):
		target_model.die_selected.connect(_on_is_selected)

func _disconnect_model_signals(target_model: DieModel) -> void:
	if target_model.rolled.is_connected(_on_dice_rolled):
		target_model.rolled.disconnect(_on_dice_rolled)
	if target_model.die_selected.is_connected(_on_is_selected):
		target_model.die_selected.disconnect(_on_is_selected)

func _on_select_pressed():
	model.select()

func _on_dice_rolled(value: int):
	die_visuals.show_value(value)

func _on_is_selected(is_selected: bool):
	die_visuals.show_selected(is_selected)
