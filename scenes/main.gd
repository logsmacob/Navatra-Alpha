extends Control

## Example scene wiring for one DieUI control.
var die_ui: DieUI


func _ready() -> void:
	die_ui = $Die
	# Quick-start path: create a standard d6 and bind it to the UI control.
	die_ui.set_die(DieInstance.create_standard_d6())


func _on_button_pressed() -> void:
	# Rolls only if the die is not currently selected/held.
	die_ui.roll_if_not_selected()
