class_name ShopTransactionPort
extends RefCounted

func spend_currency(_amount: int) -> bool:
	return false

func add_general_modifiers(_modifier_changes: Dictionary) -> void:
	pass

func add_shop_item(_item_id: String) -> void:
	pass

func add_owned_trinket(_trinket: TrinketData) -> void:
	pass

func apply_trinket_purchase_effects(_trinket: TrinketData) -> void:
	pass
