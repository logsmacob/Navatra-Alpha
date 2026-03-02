class_name HandModel
extends RefCounted

signal die_added(die: DieModel, index: int)
signal die_removed(index: int)
signal hand_changed

var dice: Array[DieModel] = []

func add_die(die: DieModel):
	dice.append(die)
	die_added.emit(die, dice.size() - 1)
	hand_changed.emit()

func remove_die(index: int):
	if index >= 0 and index < dice.size():
		dice.remove_at(index)
		die_removed.emit(index)
		hand_changed.emit()

func get_die(index: int) -> DieModel:
	return dice[index]

func get_values() -> Array[int]:
	var values: Array[int] = []
	for die in dice:
		values.append(die.current_value)
	return values
