extends Button
## Visual/controller wrapper for a single [DieInstance].
##
## Responsibilities:
## - hold/select state for reroll behavior
## - show the current face value in UI
## - expose a safe roll entry point for scene scripts
class_name DieUI

## Emitted when a roll happens from this UI control.
## [param face] is the rolled face.
signal die_rolled(face: FaceData)
signal die_selected(die_ui: DieUI)

## Runtime die backing this control.
var die: DieInstance
## If true, the die is "held" and should not roll.
var is_selected: bool = false

## Assigns the die used by this UI.
## If the die already has a current face, the label is immediately updated.
func set_die(new_die: DieInstance) -> void:
	die = new_die
	if die.current_face != null:
		text = str(die.current_face.value)


## Rolls only when this die is not selected/held.
##
## Returns:
## - [FaceData] when a roll succeeds
## - `null` when held, unassigned, or die config is invalid
func roll_if_not_selected() -> FaceData:
	if is_selected:
		return null

	if die == null:
		push_error("DieUI has no DieInstance assigned.")
		return null

	var roll_face := die.roll()
	if roll_face == null:
		return null

	text = str(roll_face.value)
	die_rolled.emit(roll_face)
	EventBus.roll_die.emit(self)
	return roll_face

func _on_pressed() -> void:
	is_selected = !is_selected
	die_selected.emit(self)
	EventBus.select_die.emit(self)
