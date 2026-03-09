extends Node
class_name DieLogic

signal die_rolled(face: FaceData)
signal die_selected(selected: bool)

var die: DieInstance
var is_selected: bool = false

func set_die(new_die: DieInstance) -> void:
	die = new_die

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
	is_selected = !is_selected
	die_selected.emit(is_selected)
