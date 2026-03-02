class_name DiceRollService

# NOTE: Rolls a single die to a random face index.
# Safe no-op for dice without faces.
static func roll_die(die: DieModel) -> void:
	var max_index := die.get_face_count() - 1
	if max_index < 0:
		return
	var index := RandomService.randi_range(0, max_index)
	die.roll_to(index)

# NOTE: Rolls all non-held dice in a set.
static func roll_all(dice_set: DiceSetModel) -> void:
	for die in dice_set.dice:
		if die.is_held():
			continue
		roll_die(die)
