extends Control
## Shop script: coordinates this part of the game's behavior.

@export var currency_label: Label
@export var inventory_label: Label
@export var offers_container: VBoxContainer
@export var reroll_button: Button
@export var continue_button: Button

@export var item_pool: Array[ItemData] = []
@export_range(1, 12, 1) var offer_count: int = 6

const REROLL_COST: int = 3

var _offers: Array[ItemData] = []

func _ready() -> void:
	_roll_offers()
	_refresh_view()

	if reroll_button:
		reroll_button.pressed.connect(_on_reroll_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	GameState.currency_changed.connect(_on_currency_changed)

func _roll_offers() -> void:
	_offers = _roll_weighted_offers(offer_count, true)
	_rebuild_offer_buttons()

func _roll_weighted_offers(target_count: int, avoid_duplicates: bool = true) -> Array[ItemData]:
	var rolled_offers: Array[ItemData] = []
	var candidate_pool: Array[ItemData] = _get_available_items_for_round()

	while rolled_offers.size() < target_count and not candidate_pool.is_empty():
		var picked_item := _pick_weighted_item(candidate_pool)
		if picked_item == null:
			break
		rolled_offers.append(picked_item)
		if avoid_duplicates:
			candidate_pool.erase(picked_item)

	return rolled_offers

func _get_available_items_for_round() -> Array[ItemData]:
	var current_round: int = max(GameState.round, 1)
	var available_items: Array[ItemData] = []
	for item: ItemData in item_pool:
		if item == null:
			continue
		if item.is_available_for_round(current_round):
			available_items.append(item)
	return available_items

func _pick_weighted_item(pool: Array[ItemData]) -> ItemData:
	var total_weight: float = 0.0
	for item: ItemData in pool:
		total_weight += max(item.weight, 0.0)
	if total_weight <= 0.0:
		return null

	var roll: float = randf_range(0.0, total_weight)
	var running_weight: float = 0.0
	for item: ItemData in pool:
		running_weight += max(item.weight, 0.0)
		if roll <= running_weight:
			return item

	return pool.back() if not pool.is_empty() else null

func _rebuild_offer_buttons() -> void:
	if offers_container == null:
		return
	for child in offers_container.get_children():
		child.queue_free()

	for i in range(_offers.size()):
		var offer: ItemData = _offers[i]
		var button := Button.new()
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = _format_offer_text(offer)
		button.pressed.connect(_on_offer_button_pressed.bind(i))
		offers_container.add_child(button)

func _on_offer_button_pressed(index: int) -> void:
	_try_buy_offer(index)

func _format_offer_text(offer: ItemData) -> String:
	return "%s [%s] | Cost %d | +%d base +%d mult | synergy +%d/%d per matching tag owned" % [
		offer.get_display_name(),
		ItemData.ItemRarity.keys()[offer.rarity].capitalize(),
		offer.cost,
		offer.base,
		offer.mult,
		offer.synergy_base,
		offer.synergy_mult,
	]

func _try_buy_offer(index: int) -> void:
	if index < 0 or index >= _offers.size():
		return

	var offer: ItemData = _offers[index]
	if not GameState.spend_currency(offer.cost):
		return

	var tag_count := GameState.get_shop_tag_count(offer.tag)
	var base_bonus := offer.base + (offer.synergy_base * tag_count)
	var mult_bonus := offer.mult + (offer.synergy_mult * tag_count)

	GameState.add_hand_type_upgrade(offer.hand_type, base_bonus, mult_bonus)
	GameState.add_shop_item(offer.id, offer.tag)
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

func _refresh_view() -> void:
	if currency_label:
		currency_label.text = "Currency: %d" % GameState.currency
	if reroll_button:
		reroll_button.text = "Reroll offers (%d)" % REROLL_COST
	var item_counts: Dictionary = GameState.get_shop_item_counts()
	var lines: Array[String] = ["Owned synergy items:"]
	for key in item_counts.keys():
		lines.append("- %s x%d" % [str(key), int(item_counts[key])])
	if item_counts.is_empty():
		lines.append("- none")
	if inventory_label:
		inventory_label.text = "\n".join(lines)
