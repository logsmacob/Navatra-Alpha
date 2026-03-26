extends Control
## Shop script: coordinates this part of the game's behavior.

@export var currency_label: CornerLabel
@export var inventory_label: Label
@export var offers_container: HBoxContainer
@export var reroll_button: Button
@export var roll_price: Label
@export var continue_button: Button
@export var trinket_button: PackedScene

@export var trinket_pool: Array[TrinketData] = []
@export_range(1, 12, 1) var offer_count: int = 4

const REROLL_COST: int = 3

var _offers: Array[TrinketData] = []
var _offer_service: ShopOfferService = ShopOfferService.new()
var _purchase_service: ShopPurchaseService = ShopPurchaseService.new()

func _ready() -> void:
	_roll_offers()
	_refresh_view()

	if reroll_button:
		reroll_button.pressed.connect(_on_reroll_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.general_modifiers_changed.connect(_on_general_modifiers_changed)

func _roll_offers() -> void:
	_offers = _offer_service.roll_weighted_offers(trinket_pool, max(GameState.round_index, 1), offer_count, true)
	_rebuild_offer_buttons()

func _rebuild_offer_buttons() -> void:
	if offers_container == null:
		return
	for child in offers_container.get_children():
		child.queue_free()

	for i in range(_offers.size()):
		var offer: TrinketData = _offers[i]
		var button := trinket_button.instantiate()
		button.set_title(offer.get_display_name())
		button.set_discription(offer.get_display_discription())
		button.set_price(offer.cost)
		button.set_rarity(TrinketData.TrinketRarity.keys()[offer.rarity])
		button.set_texture(offer._get_texture())
		button.set_border_color(offer.get_rarity_color())
		button.pressed.connect(_on_offer_button_pressed.bind(i))
		
		offers_container.add_child(button)

func _on_offer_button_pressed(index: int) -> void:
	_try_buy_offer(index)

func _try_buy_offer(index: int) -> void:
	if index < 0 or index >= _offers.size():
		return

	var offer: TrinketData = _offers[index]
	if not _purchase_service.apply_purchase(GameState, offer):
		return

	_offers.remove_at(index)
	_rebuild_offer_buttons()
	_refresh_view()

func _on_reroll_pressed() -> void:
	if not GameState.spend_currency(REROLL_COST):
		return
	_roll_offers()
	_refresh_view()

func _on_continue_pressed() -> void:
	GameState.start_next_round()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_currency_changed(_amount: int) -> void:
	_refresh_view()

func _on_general_modifiers_changed(_modifiers: Dictionary) -> void:
	_refresh_view()

func _refresh_view() -> void:
	if currency_label:
		currency_label.set_marbles(GameState.currency)
	if roll_price:
		roll_price.text = "%d" % REROLL_COST
	var trinket_counts: Dictionary = GameState.get_shop_item_counts()
	var lines: Array[String] = ["Owned trinkets:"]
	for key in trinket_counts.keys():
		lines.append("- %s x%d" % [str(key), int(trinket_counts[key])])
	if trinket_counts.is_empty():
		lines.append("- none")
	if inventory_label:
		inventory_label.text = "\n".join(lines)
