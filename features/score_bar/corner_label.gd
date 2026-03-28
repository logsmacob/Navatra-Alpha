extends PanelContainer
class_name CornerLabel

@export var _round_index_label: Label
@export var _marble_label: Label

func set_round(round_index: int, max_rounds: int) -> void:
	_round_index_label.text = "Round %d/%d" % [round_index, max_rounds]

func set_marbles(amount: int) -> void:
	_marble_label.text = " %d" % amount
