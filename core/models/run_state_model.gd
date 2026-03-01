class_name RunStateModel

# NOTE: Persisted state for the full run session.
var round_index: int = 1
var trinkets: Array[TrinketModel] = []
var is_active: bool = false

func start_new_run() -> void:
	round_index = 1
	trinkets.clear()
	is_active = true

func advance_round() -> void:
	round_index += 1

func end_run() -> void:
	is_active = false

func add_trinket(trinket: TrinketModel) -> void:
	trinkets.append(trinket)

func get_total_multiplier_bonus() -> float:
	var total := 0.0
	for trinket in trinkets:
		total += trinket.mult_bonus
	return total

func get_total_hand_base_bonus(hand_type: int) -> int:
	var total := 0
	for trinket in trinkets:
		total += trinket.get_base_bonus_for(hand_type)
	return total

func get_extra_rerolls() -> int:
	var total := 0
	for trinket in trinkets:
		total += trinket.extra_round_rerolls
	return total
