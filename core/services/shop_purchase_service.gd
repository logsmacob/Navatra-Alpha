extends RefCounted

class_name ShopPurchaseService

func can_afford_purchase(currency: int, cost: int) -> bool:
	return cost >= 0 and currency >= cost

func apply_purchase(transaction_port: ShopTransactionPort, offer: TrinketData) -> bool:
	if transaction_port == null or offer == null:
		return false
	if not transaction_port.spend_currency(offer.cost):
		return false
	transaction_port.add_general_modifiers(offer.get_general_modifier_changes())
	transaction_port.apply_trinket_purchase_effects(offer)
	transaction_port.add_shop_item(offer.get_shop_tracking_key())
	transaction_port.add_owned_trinket(offer)
	return true
