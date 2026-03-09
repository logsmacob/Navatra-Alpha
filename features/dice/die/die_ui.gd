extends Control
## Visual/controller wrapper for a single [DieInstance].
class_name DieUI

signal die_rolled(face: FaceData)
signal die_selected(selected: bool)

@onready var die_logic: DieLogic = $DieLogic

var die: DieInstance:
	get:
		return die_logic.die
	set(value):
		die_logic.set_die(value)

var is_selected: bool:
	get:
		return die_logic.is_selected
	set(value):
		die_logic.is_selected = value

func _ready() -> void:
	if not die_logic.die_rolled.is_connected(_on_logic_die_rolled):
		die_logic.die_rolled.connect(_on_logic_die_rolled)
	if not die_logic.die_selected.is_connected(_on_logic_die_selected):
		die_logic.die_selected.connect(_on_logic_die_selected)

func set_die(new_die: DieInstance) -> void:
	die_logic.set_die(new_die)
	if die != null and die.current_face != null:
		$DieFace.frame = die.current_face.value - 1

func roll_if_not_selected() -> FaceData:
	var roll_face := die_logic.roll_if_not_selected()
	if roll_face == null:
		return null

	$DieFace.frame = roll_face.value - 1
	$DieVisuals.play_roll_animation()
	return roll_face

func _on_pressed() -> void:
	die_logic.toggle_selected()

func _on_logic_die_rolled(face: FaceData) -> void:
	die_rolled.emit(face)

func _on_logic_die_selected(selected: bool) -> void:
	die_selected.emit(selected)
