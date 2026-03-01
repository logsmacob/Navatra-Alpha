extends Node

# NOTE: Central run/round orchestrator for quota, hands, and reroll budgets.
var run_state := RunStateModel.new()
var round_state := RoundStateModel.new()

func _ready() -> void:
	start_new_run()

func start_new_run() -> void:
	run_state.start_new_run()
	_start_round(run_state.round_index)
	EventBus.run_started.emit(round_state)

func _start_round(round_index: int) -> void:
	var quota := QuotaService.get_quota_for_round(round_index)
	var hands := GameBalanceConfig.get_hands_for_round(round_index)
	var rerolls := GameBalanceConfig.BASE_REROLLS_PER_ROUND + run_state.get_extra_rerolls()
	round_state.configure(round_index, quota, hands, rerolls)
	EventBus.round_started.emit(round_state)
	EventBus.round_state_changed.emit(round_state)

func can_use_reroll() -> bool:
	return round_state.can_reroll()

func spend_reroll() -> bool:
	var spent := round_state.spend_reroll()
	if spent:
		EventBus.round_state_changed.emit(round_state)
	return spent

func submit_hand(result: HandResult, values: Array[int]) -> int:
	if not round_state.consume_hand():
		return 0

	var score := ScoreCalculatorService.calculate(result, values, run_state)
	round_state.apply_score(score)
	EventBus.hand_scored.emit(score, round_state.current_quota)
	EventBus.round_state_changed.emit(round_state)

	if round_state.is_cleared():
		EventBus.round_cleared.emit(round_state)
		run_state.advance_round()
		_start_round(run_state.round_index)
	elif round_state.is_failed():
		run_state.end_run()
		EventBus.run_failed.emit(round_state)

	return score

func add_trinket(trinket: TrinketModel) -> void:
	run_state.add_trinket(trinket)
	EventBus.trinket_added.emit(trinket)
