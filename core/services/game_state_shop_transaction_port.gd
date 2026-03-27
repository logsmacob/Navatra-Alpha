class_name GameStateShopTransactionPort
extends ShopTransactionPort

const REQUIRED_METHODS := [
	"spend_currency",
	"add_general_modifiers",
	"add_shop_item",
	"add_owned_trinket",
]

var _game_state: Object
var _has_valid_contract: bool = false

func _init(game_state: Object) -> void:
	_game_state = game_state
	_has_valid_contract = _validate_contract()

func _validate_contract() -> bool:
	if _game_state == null:
		push_error("GameStateShopTransactionPort: game_state dependency is null.")
		return false
	for method_name in REQUIRED_METHODS:
		if _game_state.has_method(method_name):
			continue
		push_error("GameStateShopTransactionPort: game_state is missing required method '%s'." % method_name)
		return false
	return true

func spend_currency(amount: int) -> bool:
	if not _has_valid_contract:
		return false
	return bool(_game_state.call("spend_currency", amount))

func add_general_modifiers(modifier_changes: Dictionary) -> void:
	if not _has_valid_contract:
		return
	_game_state.call("add_general_modifiers", modifier_changes)

func add_shop_item(item_id: String) -> void:
	if not _has_valid_contract:
		return
	_game_state.call("add_shop_item", item_id)

func add_owned_trinket(trinket: TrinketData) -> void:
	if not _has_valid_contract:
		return
	_game_state.call("add_owned_trinket", trinket)

func apply_trinket_purchase_effects(trinket: TrinketData) -> void:
	if not _has_valid_contract or trinket == null:
		return
	trinket.apply_purchase_effects(_game_state)
