extends Control
## Visual/controller wrapper for a single [DieInstance].
class_name DieUI

signal die_rolled(face: FaceData)
signal die_roll_animation_finished(die: DieUI)
signal die_selected(selected: bool)

@onready var die_logic: DieLogic = $DieLogic
@onready var die_visuals: DieVisuals = $DieVisuals
@onready var input_button: Button = $Button

var die: DieInstance:
	get:
		return die_logic.die
	set(value):
		die_logic.set_die(value)

var is_selected: bool:
	get:
		return die_logic.is_selected
	set(value):
		die_logic.set_selected(value)

var is_interaction_enabled: bool = true

func set_die(new_die: DieInstance) -> void:
	die_logic.set_die(new_die)
	if die != null and die.current_face != null:
		die_visuals.set_face(die.current_face.value)

func roll_if_not_selected(duration: float) -> FaceData:
	var roll_face := die_logic.roll_if_not_selected()
	if roll_face == null:
		return null

	die_visuals.play_roll_animation(roll_face.value, duration)
	return roll_face

func _on_pressed() -> void:
	die_logic.toggle_selected()

func _on_logic_die_rolled(face: FaceData) -> void:
	die_rolled.emit(face)

func _on_logic_die_selected(selected: bool) -> void:
	die_selected.emit(selected)

func _on_die_visuals_anim_roll_finished(_die: DieUI) -> void:
	die_roll_animation_finished.emit(self)

func set_interaction_enabled(enabled: bool) -> void:
	is_interaction_enabled = enabled
	if input_button != null:
		input_button.disabled = not enabled
