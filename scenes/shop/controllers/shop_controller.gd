extends Node
## Shop controller script: handles shop flow orchestration between GameState and ShopView.
class_name ShopController

const DEFAULT_MAIN_SCENE := preload("res://scenes/main/main.tscn")
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const TRINKET_DATA_ROOT := "res://data/shop/trinkets"
const DEFAULT_BALANCE_CONFIG := preload("res://data/config/balance/shop_balance.tres")

@export var shop_view: ShopView
@export var trinket_pool: Array[TrinketData] = []
@export var main_scene: PackedScene = DEFAULT_MAIN_SCENE
## Tunable shop economy and rarity settings.
@export var balance_config: ShopBalanceConfig = DEFAULT_BALANCE_CONFIG

var _offers: Array[TrinketData] = []
var _offer_service: ShopOfferService = ShopOfferService.new()
var _purchase_service: ShopPurchaseService = ShopPurchaseService.new()
var _transaction_port: ShopTransactionPort
var _shop_rerolls_purchased: int = 0

func _ready() -> void:
	if shop_view == null:
		return

	_populate_trinket_pool_from_data()
	_shop_rerolls_purchased = 0
	_apply_balance_config()
	_transaction_port = GameStateShopTransactionPort.new(GameState)
	shop_view.offer_purchase_requested.connect(_on_offer_purchase_requested)
	shop_view.reroll_requested.connect(_on_reroll_requested)
	shop_view.continue_requested.connect(_on_continue_requested)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)

	shop_view.set_roll_cost(_get_scaled_shop_reroll_cost())
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
	var reroll_cost := _get_scaled_shop_reroll_cost()
	if not _purchase_service.can_afford_purchase(GameState.currency, reroll_cost):
		return
	if not GameState.spend_currency(reroll_cost):
		return

	_shop_rerolls_purchased += 1
	_roll_offers()
	_refresh_view()

func _on_continue_requested() -> void:
	GameState.start_next_round()
	var target_scene := _resolve_main_scene()
	if target_scene == null:
		push_warning("ShopController: main_scene is not assigned or invalid.")
		return
	var scene_tree := get_tree()
	if scene_tree != null:
		scene_tree.change_scene_to_packed(target_scene)

func _resolve_main_scene() -> PackedScene:
	if main_scene != null and main_scene.can_instantiate():
		return main_scene
	if DEFAULT_MAIN_SCENE != null and DEFAULT_MAIN_SCENE.can_instantiate():
		return DEFAULT_MAIN_SCENE
	var loaded_main_scene := load(MAIN_SCENE_PATH) as PackedScene
	if loaded_main_scene != null and loaded_main_scene.can_instantiate():
		return loaded_main_scene
	return null

func _on_currency_changed(_amount: int) -> void:
	_refresh_view()

func _on_general_modifiers_changed(_modifiers: Dictionary) -> void:
	_refresh_view()

func _roll_offers() -> void:
	var rolled_offers := _offer_service.roll_weighted_offers(
		trinket_pool,
		max(GameState.round_index, 1),
		_get_offer_count(),
		true,
		GameState.get_shop_item_counts()
	)
	_offers.clear()
	for offer: TrinketData in rolled_offers:
		if offer == null:
			continue
		_offers.append(_build_round_scaled_offer(offer))
	shop_view.set_offers(_offers, GameState.currency)

func _refresh_view() -> void:
	if shop_view == null:
		return
	var reroll_cost := _get_scaled_shop_reroll_cost()
	shop_view.set_currency_display(GameState.currency)
	shop_view.set_roll_cost(reroll_cost)
	shop_view.set_reroll_enabled(_purchase_service.can_afford_purchase(GameState.currency, reroll_cost))
	shop_view.refresh_offer_affordability(GameState.currency)
	shop_view.set_inventory_lines(_build_inventory_lines(GameState.get_owned_trinkets()))

func _build_round_scaled_offer(source_offer: TrinketData) -> TrinketData:
	var priced_offer := source_offer.duplicate(true) as TrinketData
	if priced_offer == null:
		return source_offer
	priced_offer.cost = _get_scaled_cost(source_offer.cost)
	return priced_offer

func _get_scaled_shop_reroll_cost() -> int:
	var reroll_base_cost := balance_config.reroll_base_cost if balance_config != null else 1
	var reroll_escalation_step := balance_config.reroll_escalation_step if balance_config != null else 0
	return _get_scaled_cost(reroll_base_cost) + (_shop_rerolls_purchased * reroll_escalation_step)

func _get_scaled_cost(base_cost: int) -> int:
	if base_cost <= 0:
		return 0
	var current_round = max(GameState.round_index, 1)
	var round_cost_multiplier_step := balance_config.round_cost_multiplier_step if balance_config != null else 0.1
	var cost_discount_factor := balance_config.cost_discount_factor if balance_config != null else 0.75
	var round_multiplier := 1.0 + (float(current_round - 1) * round_cost_multiplier_step)
	return maxi(int(ceil(float(base_cost) * round_multiplier * cost_discount_factor)), 1)

func _get_offer_count() -> int:
	if balance_config == null:
		return 4
	return maxi(balance_config.trinket_option_count, 1)

func _apply_balance_config() -> void:
	if balance_config == null:
		return
	_offer_service.set_rarity_weights(balance_config.get_rarity_weights())

func _populate_trinket_pool_from_data() -> void:
	var discovered_trinkets := _load_trinkets_recursive(TRINKET_DATA_ROOT)
	if discovered_trinkets.is_empty():
		return

	var merged_pool: Array[TrinketData] = []
	var seen_keys: Dictionary = {}
	for trinket: TrinketData in trinket_pool:
		if trinket == null:
			continue
		var key := trinket.get_shop_tracking_key()
		if seen_keys.has(key):
			continue
		seen_keys[key] = true
		merged_pool.append(trinket)

	for trinket: TrinketData in discovered_trinkets:
		if trinket == null:
			continue
		var key := trinket.get_shop_tracking_key()
		if seen_keys.has(key):
			continue
		seen_keys[key] = true
		merged_pool.append(trinket)

	trinket_pool = merged_pool

func _load_trinkets_recursive(root_path: String) -> Array[TrinketData]:
	var loaded: Array[TrinketData] = []
	var directory := DirAccess.open(root_path)
	if directory == null:
		return loaded

	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry.is_empty():
			break
		if entry.begins_with("."):
			continue

		var full_path := "%s/%s" % [root_path, entry]
		if directory.current_is_dir():
			loaded.append_array(_load_trinkets_recursive(full_path))
			continue
		if not entry.ends_with(".tres"):
			continue

		var resource := load(full_path)
		var trinket := resource as TrinketData
		if trinket == null:
			continue
		loaded.append(trinket)

	directory.list_dir_end()
	return loaded

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
