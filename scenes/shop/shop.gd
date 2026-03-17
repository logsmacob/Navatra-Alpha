extends Control
## Shop script: coordinates this part of the game's behavior.

@export var currency_label: Label
@export var inventory_label: Label
@export var offers_container: VBoxContainer
@export var reroll_button: Button
@export var continue_button: Button

const OFFER_COUNT: int = 6
const REROLL_COST: int = 3

const ITEM_POOL := [
	{"id": "sparking_ring", "name": "Sparking Ring", "cost": 5, "hand_type": 0, "tag": "elemental", "base": 1, "mult": 0, "synergy_base": 1, "synergy_mult": 0},
	{"id": "ace_scope", "name": "Ace Scope", "cost": 6, "hand_type": 7, "tag": "precision", "base": 0, "mult": 1, "synergy_base": 0, "synergy_mult": 1},
	{"id": "pair_gloves", "name": "Pair Gloves", "cost": 5, "hand_type": 1, "tag": "precision", "base": 1, "mult": 0, "synergy_base": 1, "synergy_mult": 0},
	{"id": "house_banner", "name": "House Banner", "cost": 8, "hand_type": 6, "tag": "royal", "base": 2, "mult": 0, "synergy_base": 1, "synergy_mult": 1},
	{"id": "street_bet", "name": "Street Bet", "cost": 4, "hand_type": 0, "tag": "economy", "base": 0, "mult": 1, "synergy_base": 1, "synergy_mult": 0},
	{"id": "triple_badge", "name": "Triple Badge", "cost": 7, "hand_type": 3, "tag": "combo", "base": 1, "mult": 1, "synergy_base": 1, "synergy_mult": 1},
	{"id": "flush_charm", "name": "Flush Charm", "cost": 7, "hand_type": 5, "tag": "elemental", "base": 2, "mult": 0, "synergy_base": 1, "synergy_mult": 0},
	{"id": "high_roller", "name": "High Roller", "cost": 9, "hand_type": 7, "tag": "royal", "base": 1, "mult": 1, "synergy_base": 0, "synergy_mult": 1},
	{"id": "full_house_manual", "name": "Full House Manual", "cost": 8, "hand_type": 4, "tag": "combo", "base": 2, "mult": 0, "synergy_base": 1, "synergy_mult": 1},
	{"id": "oddity_ink", "name": "Oddity Ink", "cost": 5, "hand_type": 2, "tag": "economy", "base": 1, "mult": 0, "synergy_base": 1, "synergy_mult": 0}
]

var _offers: Array[Dictionary] = []

func _ready() -> void:
	_bind_nodes()
	_roll_offers()
	_refresh_view()

	if reroll_button:
		reroll_button.pressed.connect(_on_reroll_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	GameState.currency_changed.connect(_on_currency_changed)

func _bind_nodes() -> void:
	if currency_label == null:
		currency_label = get_node_or_null("Margin/VBox/Currency")
	if inventory_label == null:
		inventory_label = get_node_or_null("Margin/VBox/Inventory")
	if offers_container == null:
		offers_container = get_node_or_null("Margin/VBox/Offers")
	if reroll_button == null:
		reroll_button = get_node_or_null("Margin/VBox/RerollButton")
	if continue_button == null:
		continue_button = get_node_or_null("Margin/VBox/ContinueButton")

func _roll_offers() -> void:
	_offers.clear()
	var pool_copy: Array[Dictionary] = []
	for item: Dictionary in ITEM_POOL:
		pool_copy.append(item.duplicate(true))
	pool_copy.shuffle()
	for i in range(min(OFFER_COUNT, pool_copy.size())):
		_offers.append(pool_copy[i])
	_rebuild_offer_buttons()

func _rebuild_offer_buttons() -> void:
	if offers_container == null:
		return
	for child in offers_container.get_children():
		child.queue_free()

	for i in range(_offers.size()):
		var offer: Dictionary = _offers[i]
		var button := Button.new()
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = _format_offer_text(offer)
		button.pressed.connect(_on_offer_button_pressed.bind(i))
		offers_container.add_child(button)

func _on_offer_button_pressed(index: int) -> void:
	_try_buy_offer(index)

func _format_offer_text(offer: Dictionary) -> String:
	return "%s | %s tag | Cost %d | +%d base +%d mult | synergy +%d/%d per matching tag owned" % [
		str(offer.get("name", "Item")),
		str(offer.get("tag", "general")),
		int(offer.get("cost", 0)),
		int(offer.get("base", 0)),
		int(offer.get("mult", 0)),
		int(offer.get("synergy_base", 0)),
		int(offer.get("synergy_mult", 0))
	]

func _try_buy_offer(index: int) -> void:
	if index < 0 or index >= _offers.size():
		return

	var offer: Dictionary = _offers[index]
	var cost := int(offer.get("cost", 0))
	if not GameState.spend_currency(cost):
		return

	var tag := str(offer.get("tag", ""))
	var tag_count := GameState.get_shop_tag_count(tag)
	var base_bonus := int(offer.get("base", 0)) + (int(offer.get("synergy_base", 0)) * tag_count)
	var mult_bonus := int(offer.get("mult", 0)) + (int(offer.get("synergy_mult", 0)) * tag_count)
	var hand_type := int(offer.get("hand_type", 0))

	GameState.add_hand_type_upgrade(hand_type, base_bonus, mult_bonus)
	GameState.add_shop_item(str(offer.get("id", "unknown")), tag)
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
