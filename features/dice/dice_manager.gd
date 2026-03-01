extends Node

# NOTE: Coordinates dice lifecycle and hand evaluation for the current play field.
var dice_set: DiceSetModel = DiceSetModel.new()

func _ready() -> void:
	# NOTE: Create default 5 six-sided dice.
	for i in 5:
		var die: DieModel = DieModel.new([1, 2, 3, 4, 5, 6])
		dice_set.add_die(die)

	# NOTE: EventBus integration keeps UI/input systems decoupled from dice logic.
	if EventBus.roll_all_dice_requested.is_connected(roll_all) == false:
		EventBus.roll_all_dice_requested.connect(roll_all)

func roll_all() -> void:
	# NOTE: First roll for a hand is free. Extra full rolls spend from round reroll budget.
	if dice_set.all_rolled():
		if not GameSessionService.spend_reroll():
			return
	DiceRollService.roll_all(dice_set)

func evaluate() -> HandResult:
	var result: HandResult = HandEvaluatorModel.evaluate(dice_set.get_values())
	EventBus.dice_evaluated.emit(result)
	return result

func evaluate_and_submit() -> int:
	var result: HandResult = evaluate()
	if not result.is_complete:
		return 0
	var score: int = GameSessionService.submit_hand(result, dice_set.get_values())
	dice_set.reset()
	return score

func reset_round() -> void:
	# NOTE: Exposed for future round-state orchestration.
	dice_set.reset()
