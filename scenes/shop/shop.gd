extends Control

@export var currency_label: Label
@export var hand_summary_label: Label

@export var face_die_option: OptionButton
@export var face_index_option: OptionButton
@export var face_value_option: OptionButton
@export var buy_face_button: Button

@export var material_die_option: OptionButton
@export var material_option: OptionButton
@export var buy_material_button: Button

@export var continue_button: Button

const FACE_UPGRADE_COST: int = 4
const MATERIAL_COSTS := {
	GameState.DIE_MATERIAL_STEEL: 6,
	GameState.DIE_MATERIAL_GOLDEN: 10,
}

func _ready() -> void:
	_populate_options()
	_refresh_view()

	buy_face_button.pressed.connect(_on_buy_face_pressed)
	buy_material_button.pressed.connect(_on_buy_material_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.player_hand_changed.connect(_on_player_hand_changed)
	material_option.item_selected.connect(_on_material_option_selected)

func _populate_options() -> void:
	face_die_option.clear()
	material_die_option.clear()
	face_index_option.clear()
	face_value_option.clear()
	material_option.clear()

	var hand: Array[Dictionary] = GameState.get_player_hand()
	for i in range(hand.size()):
		var label := "Die %d" % (i + 1)
		face_die_option.add_item(label, i)
		material_die_option.add_item(label, i)

	for i in range(6):
		face_index_option.add_item("Face %d" % (i + 1), i)
		face_value_option.add_item(str(i + 1), i + 1)

	material_option.add_item("Steel (+1 currency / hand)", 0)
	material_option.set_item_metadata(0, GameState.DIE_MATERIAL_STEEL)
	material_option.add_item("Golden (+2 currency / hand)", 1)
	material_option.set_item_metadata(1, GameState.DIE_MATERIAL_GOLDEN)

func _on_buy_face_pressed() -> void:
	if not GameState.spend_currency(FACE_UPGRADE_COST):
		return

	var die_index := face_die_option.get_selected_id()
	var face_index := face_index_option.get_selected_id()
	var value := face_value_option.get_selected_id()

	if not GameState.set_die_face_value(die_index, face_index, value):
		GameState.add_currency(FACE_UPGRADE_COST)

func _on_buy_material_pressed() -> void:
	if material_option.item_count == 0 or material_die_option.item_count == 0:
		return

	var die_index := material_die_option.get_selected_id()
	var selected_material_index: int = maxi(material_option.selected, 0)
	var selected_material := str(material_option.get_item_metadata(selected_material_index))
	var cost := int(MATERIAL_COSTS.get(selected_material, 999))

	if not GameState.spend_currency(cost):
		return

	if not GameState.set_die_material(die_index, selected_material):
		GameState.add_currency(cost)

func _on_continue_pressed() -> void:
	GameState.start_next_round()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_currency_changed(_amount: int) -> void:
	_refresh_view()

func _on_player_hand_changed(_hand_state: Array) -> void:
	_refresh_view()

func _refresh_view() -> void:
	currency_label.text = "Currency: %d" % GameState.currency

	if material_option.item_count == 0:
		buy_material_button.text = "Buy Material"
		return

	var lines: Array[String] = []
	var hand := GameState.get_player_hand()
	for i in range(hand.size()):
		var die_data: Dictionary = hand[i]
		lines.append("Die %d | material=%s | faces=%s" % [
			i + 1,
			str(die_data.get("material", GameState.DIE_MATERIAL_STANDARD)),
			str(die_data.get("faces", []))
		])
	hand_summary_label.text = "\n".join(lines)

	buy_face_button.text = "Buy Face Upgrade (%d)" % FACE_UPGRADE_COST
	var selected_material_index: int = maxi(material_option.selected, 0)
	var selected_material := str(material_option.get_item_metadata(selected_material_index))
	buy_material_button.text = "Buy Material (%d)" % int(MATERIAL_COSTS.get(selected_material, 0))

func _on_material_option_selected(_index: int) -> void:
	_refresh_view()
