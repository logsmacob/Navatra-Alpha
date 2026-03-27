extends Control
## Shop view script: renders shop data and emits user intent signals.
class_name ShopView

signal offer_purchase_requested(index: int)
signal reroll_requested
signal continue_requested

@export var currency_label: CornerLabel
@export var inventory_label: Label
@export var offers_container: HBoxContainer
@export var reroll_button: Button
@export var roll_price: Label
@export var continue_button: Button
@export var trinket_button: PackedScene

var _offers: Array[TrinketData] = []
var _offer_buttons: Array[Button] = []

func _ready() -> void:
	if reroll_button:
		reroll_button.pressed.connect(_on_reroll_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)

func set_roll_cost(cost: int) -> void:
	if roll_price:
		roll_price.text = "%d" % cost

func set_currency_display(amount: int) -> void:
	if currency_label:
		currency_label.set_marbles(amount)

func set_offers(offers: Array[TrinketData], currency_amount: int) -> void:
	_offers = offers.duplicate()
	_rebuild_offer_buttons(currency_amount)

func set_inventory_lines(lines: Array[String]) -> void:
	if inventory_label:
		inventory_label.text = "\n".join(lines)

func set_reroll_enabled(enabled: bool) -> void:
	if reroll_button:
		reroll_button.disabled = not enabled

func refresh_offer_affordability(currency_amount: int) -> void:
	for i in range(_offer_buttons.size()):
		var button := _offer_buttons[i]
		if button == null:
			continue
		if i < 0 or i >= _offers.size():
			button.disabled = true
			continue
		var offer := _offers[i]
		button.disabled = currency_amount < offer.cost

func _rebuild_offer_buttons(currency_amount: int) -> void:
	if offers_container == null:
		return

	_offer_buttons.clear()
	for child in offers_container.get_children():
		child.queue_free()

	if _offers.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No offers available this round."
		offers_container.add_child(empty_label)
		return

	for i in range(_offers.size()):
		var offer: TrinketData = _offers[i]
		var button := trinket_button.instantiate()
		button.set_title(offer.get_display_name())
		button.set_description(offer.get_display_description())
		button.set_price(offer.cost)
		button.set_rarity(TrinketData.TrinketRarity.keys()[offer.rarity])
		button.set_texture(offer._get_texture())
		button.set_border_color(offer.get_rarity_color())
		button.pressed.connect(_on_offer_button_pressed.bind(i))
		button.tooltip_text = "%s\nCost: %d marbles" % [offer.get_display_name(), offer.cost]
		offers_container.add_child(button)
		_offer_buttons.append(button)

	refresh_offer_affordability(currency_amount)

func _on_offer_button_pressed(index: int) -> void:
	offer_purchase_requested.emit(index)

func _on_reroll_pressed() -> void:
	reroll_requested.emit()

func _on_continue_pressed() -> void:
	continue_requested.emit()
