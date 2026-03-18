extends RefCounted

class_name ShopPurchaseService

func can_afford_purchase(currency: int, cost: int) -> bool:
	return cost >= 0 and currency >= cost

func apply_purchase(game_state: Node, offer: ItemData) -> bool:
	if game_state == null or offer == null:
		return false
	if not game_state.has_method("spend_currency"):
		return false
	if not game_state.call("spend_currency", offer.cost):
		return false
	if game_state.has_method("add_hand_type_upgrade"):
		game_state.call("add_hand_type_upgrade", offer.hand_type, offer.base, offer.mult)
	if game_state.has_method("add_general_modifiers"):
		game_state.call("add_general_modifiers", offer.get_general_modifier_changes())
	if game_state.has_method("add_shop_item"):
		game_state.call("add_shop_item", offer.id)
	return true
