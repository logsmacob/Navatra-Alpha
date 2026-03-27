class_name GameStateShopTransactionPort
extends ShopTransactionPort

var _game_state: Node

func _init(game_state: Node) -> void:
	_game_state = game_state

func spend_currency(amount: int) -> bool:
	if _game_state == null:
		return false
	if not _game_state.has_method("spend_currency"):
		return false
	return bool(_game_state.call("spend_currency", amount))

func add_general_modifiers(modifier_changes: Dictionary) -> void:
	if _game_state == null:
		return
	if _game_state.has_method("add_general_modifiers"):
		_game_state.call("add_general_modifiers", modifier_changes)

func add_shop_item(item_id: String) -> void:
	if _game_state == null:
		return
	if _game_state.has_method("add_shop_item"):
		_game_state.call("add_shop_item", item_id)

func add_owned_trinket(trinket: TrinketData) -> void:
	if _game_state == null:
		return
	if _game_state.has_method("add_owned_trinket"):
		_game_state.call("add_owned_trinket", trinket)

func apply_trinket_purchase_effects(trinket: TrinketData) -> void:
	if trinket == null:
		return
	trinket.apply_purchase_effects(_game_state)
