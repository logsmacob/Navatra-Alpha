extends Control
## Shop view script: renders shop data and emits user intent signals.
class_name ShopView

signal offer_purchase_requested(index: int)
signal offer_lock_toggled(index: int, is_locked: bool)
signal reroll_requested
signal continue_requested

@export var currency_label: CornerLabel
@export var inventory_container: VBoxContainer
@export var offers_container: HBoxContainer
@export var reroll_button: Button
@export var roll_price: Label
@export var continue_button: Button
@export var trinket_button: PackedScene

var _offers: Array[TrinketData] = []
var _offer_buttons: Array[Button] = []
var _locked_offer_keys: Dictionary = {}

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

func set_round_display(round_index: int, max_rounds: int) -> void:
	if currency_label:
		currency_label.set_round(round_index, max_rounds)

func set_offers(offers: Array[TrinketData], currency_amount: int, locked_offer_keys: Dictionary = {}) -> void:
	_offers = offers.duplicate()
	_locked_offer_keys = locked_offer_keys.duplicate(true)
	_rebuild_offer_buttons(currency_amount)

func set_inventory_entries(entries: Array[Dictionary]) -> void:
	if inventory_container == null:
		return

	for child in inventory_container.get_children():
		child.queue_free()

	var title_label := Label.new()
	title_label.text = "Owned trinkets:"
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_container.add_child(title_label)

	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "- none"
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inventory_container.add_child(empty_label)
		return

	for entry in entries:
		var item_button := Button.new()
		item_button.flat = true
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_button.text = "- %s x%d" % [str(entry.get("name", "Unknown")), int(entry.get("count", 0))]
		item_button.tooltip_text = str(entry.get("description", "No description available."))
		inventory_container.add_child(item_button)

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
		button.set_texture(offer.get_texture())
		button.set_border_color(offer.get_rarity_color())
		button.pressed.connect(_on_offer_button_pressed.bind(i))
		if button.has_method("set_locked"):
			var offer_key := offer.get_shop_tracking_key()
			button.set_locked(bool(_locked_offer_keys.get(offer_key, false)))
		if button.has_signal("lock_toggled"):
			button.lock_toggled.connect(_on_offer_lock_toggled.bind(i))
		button.tooltip_text = "%s\nCost: %d marbles" % [offer.get_display_name(), offer.cost]
		offers_container.add_child(button)
		_offer_buttons.append(button)

	refresh_offer_affordability(currency_amount)

func _on_offer_button_pressed(index: int) -> void:
	offer_purchase_requested.emit(index)

func _on_offer_lock_toggled(is_locked: bool, index: int) -> void:
	offer_lock_toggled.emit(index, is_locked)

func _on_reroll_pressed() -> void:
	reroll_requested.emit()

func _on_continue_pressed() -> void:
	continue_requested.emit()
