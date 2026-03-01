extends Node

# NOTE: Coordinates dice lifecycle and hand evaluation for the current play field.
var dice_set := DiceSetModel.new()

func _ready() -> void:
	# NOTE: Create default 5 six-sided dice.
	for i in 5:
		var die := DieModel.new([1, 2, 3, 4, 5, 6])
		dice_set.add_die(die)

	# NOTE: EventBus integration keeps UI/input systems decoupled from dice logic.
	if EventBus.roll_all_dice_requested.is_connected(roll_all) == false:
		EventBus.roll_all_dice_requested.connect(roll_all)

func roll_all() -> void:
	DiceRollService.roll_all(dice_set)

func evaluate() -> HandResult:
	var result := HandEvaluatorModel.evaluate(dice_set.get_values())
	EventBus.dice_evaluated.emit(result)
	return result

func reset_round() -> void:
	# NOTE: Exposed for future round-state orchestration.
	dice_set.reset()
