class_name DiceSetModel

# NOTE: Collection model for the dice currently in play.
var dice: Array[DieModel] = []

func add_die(die: DieModel) -> void:
	dice.append(die)

func get_values() -> Array[int]:
	var values: Array[int] = []
	for die in dice:
		values.append(die.get_value())
	return values

func all_rolled() -> bool:
	# NOTE: Returns true only when every die has been rolled at least once.
	for die in dice:
		if not die.has_value():
			return false
	return true

func reset() -> void:
	# NOTE: Clears all dice roll states at round boundaries.
	for die in dice:
		die.reset()
