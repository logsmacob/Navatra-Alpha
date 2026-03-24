extends Node

## Die logic script: coordinates this part of the game's behavior.
class_name DieLogic

signal die_rolled(face: FaceData)
signal die_selected(selected: bool)

var die: DieInstance
var is_selected: bool = false

func set_die(new_die: DieInstance) -> void:
	die = new_die

func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	is_selected = selected
	die_selected.emit(is_selected)

func roll_if_not_selected() -> FaceData:
	if is_selected:
		return null

	if die == null:
		push_error("DieLogic has no DieInstance assigned.")
		return null

	var roll_face := die.roll()
	if roll_face == null:
		return null

	die_rolled.emit(roll_face)
	return roll_face

func toggle_selected() -> void:
	set_selected(!is_selected)
