extends Node

@export var panel : Panel

func _on_die_die_selected(die_ui: DieUI) -> void:
	if die_ui.is_selected:
		panel.modulate = Color.DIM_GRAY
	else:
		panel.modulate = Color.WHITE
