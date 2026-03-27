extends Node
## Shop controller script: handles shop flow orchestration between GameState and ShopView.
class_name ShopController

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const REROLL_COST: int = 3

@export var shop_view: ShopView
@export var trinket_pool: Array[TrinketData] = []
@export_range(1, 12, 1) var offer_count: int = 4

var _offers: Array[TrinketData] = []
var _offer_service: ShopOfferService = ShopOfferService.new()
var _purchase_service: ShopPurchaseService = ShopPurchaseService.new()
var _transaction_port: ShopTransactionPort

func _ready() -> void:
	if shop_view == null:
		return

	_transaction_port = GameStateShopTransactionPort.new(GameState)
	shop_view.offer_purchase_requested.connect(_on_offer_purchase_requested)
	shop_view.reroll_requested.connect(_on_reroll_requested)
	shop_view.continue_requested.connect(_on_continue_requested)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)

	shop_view.set_roll_cost(REROLL_COST)
	_roll_offers()
	_refresh_view()

func _on_offer_purchase_requested(index: int) -> void:
	if index < 0 or index >= _offers.size():
		return

	var offer: TrinketData = _offers[index]
	if not _purchase_service.apply_purchase(_transaction_port, offer):
		return

	_offers.remove_at(index)
	shop_view.set_offers(_offers, GameState.currency)
	_refresh_view()

func _on_reroll_requested() -> void:
	if not _purchase_service.can_afford_purchase(GameState.currency, REROLL_COST):
		return
	if not GameState.spend_currency(REROLL_COST):
		return

	_roll_offers()
	_refresh_view()

func _on_continue_requested() -> void:
	GameState.start_next_round()
	var scene_tree := get_tree()
	if scene_tree != null:
		scene_tree.change_scene_to_file(MAIN_SCENE_PATH)

func _on_currency_changed(_amount: int) -> void:
	_refresh_view()

func _on_general_modifiers_changed(_modifiers: Dictionary) -> void:
	_refresh_view()

func _roll_offers() -> void:
	_offers = _offer_service.roll_weighted_offers(
		trinket_pool,
		max(GameState.round_index, 1),
		offer_count,
		true,
		GameState.get_shop_item_counts()
	)
	shop_view.set_offers(_offers, GameState.currency)

func _refresh_view() -> void:
	if shop_view == null:
		return
	shop_view.set_currency_display(GameState.currency)
	shop_view.set_reroll_enabled(_purchase_service.can_afford_purchase(GameState.currency, REROLL_COST))
	shop_view.refresh_offer_affordability(GameState.currency)
	shop_view.set_inventory_lines(_build_inventory_lines(GameState.get_owned_trinkets()))

func _build_inventory_lines(owned_trinkets: Array[TrinketData]) -> Array[String]:
	var trinket_counts: Dictionary = {}
	for owned_trinket: TrinketData in owned_trinkets:
		if owned_trinket == null:
			continue
		var trinket_name := owned_trinket.get_display_name()
		trinket_counts[trinket_name] = int(trinket_counts.get(trinket_name, 0)) + 1

	var lines: Array[String] = ["Owned trinkets:"]
	var sorted_names: Array = trinket_counts.keys()
	sorted_names.sort_custom(func(a: Variant, b: Variant) -> bool:
		return str(a).nocasecmp_to(str(b)) < 0
	)
	for key in sorted_names:
		lines.append("- %s x%d" % [str(key), int(trinket_counts[key])])
	if trinket_counts.is_empty():
		lines.append("- none")
	return lines
