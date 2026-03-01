class_name TrinketModel

# NOTE: Lightweight runtime trinket representation.
var id: String = ""
var display_name: String = ""

# NOTE: Added into total multiplier as additive bonus.
var mult_bonus: float = 0.0

# NOTE: Round-level reroll extension.
var extra_round_rerolls: int = 0

# NOTE: Optional hand-specific base bonuses keyed by HandEvaluatorModel.HandType.
var base_bonus_by_hand_type: Dictionary = {}

func _init(
	p_id: String = "",
	p_name: String = "",
	p_mult_bonus: float = 0.0,
	p_extra_round_rerolls: int = 0,
	p_base_bonus_by_hand_type: Dictionary = {}
) -> void:
	id = p_id
	display_name = p_name
	mult_bonus = p_mult_bonus
	extra_round_rerolls = p_extra_round_rerolls
	base_bonus_by_hand_type = p_base_bonus_by_hand_type.duplicate()

func get_base_bonus_for(hand_type: int) -> int:
	if not base_bonus_by_hand_type.has(hand_type):
		return 0
	return int(base_bonus_by_hand_type[hand_type])
