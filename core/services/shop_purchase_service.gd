extends RefCounted

class_name ShopPurchaseService

func can_afford_purchase(currency: int, cost: int) -> bool:
	return cost >= 0 and currency >= cost

func apply_purchase(game_state: Node, offer: TrinketData) -> bool:
	if game_state == null or offer == null:
		return false
	if not game_state.has_method("spend_currency"):
		return false
	if not game_state.call("spend_currency", offer.cost):
		return false
	if game_state.has_method("add_general_modifiers"):
		game_state.call("add_general_modifiers", offer.get_general_modifier_changes())
	_apply_triggered_scoring_modifiers(game_state, offer)
	if game_state.has_method("add_shop_item"):
		game_state.call("add_shop_item", offer.id)
	return true

func _apply_triggered_scoring_modifiers(game_state: Node, offer: TrinketData) -> void:
	var base_bonus := int(offer.base)
	var mult_bonus := int(offer.mult)
	if base_bonus == 0 and mult_bonus == 0:
		return

	match offer.trigger_type:
		TrinketData.TriggerType.ON_HAND_TYPE:
			if game_state.has_method("add_hand_type_upgrade"):
				game_state.call("add_hand_type_upgrade", int(offer.hand_type), base_bonus, mult_bonus)
		TrinketData.TriggerType.ON_FACE_VALUE:
			if game_state.has_method("add_general_modifiers"):
				var face_value := clampi(int(offer.trigger_face_value), 1, 6)
				game_state.call("add_general_modifiers", {
					"base_%d_value" % face_value: base_bonus,
					"mult_%d_value" % face_value: mult_bonus,
				})
		_:
			if not game_state.has_method("add_hand_type_upgrade"):
				return
			for hand_type in HandEvaluatorService.HandType.values():
				game_state.call("add_hand_type_upgrade", int(hand_type), base_bonus, mult_bonus)
