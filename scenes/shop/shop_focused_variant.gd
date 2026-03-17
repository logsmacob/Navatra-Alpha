extends Control

@export var currency_label: Label
@export var info_label: Label
@export var precision_button: Button
@export var economy_button: Button
@export var tempo_button: Button
@export var continue_button: Button

const PRECISION_COST: int = 10
const ECONOMY_COST: int = 10
const TEMPO_COST: int = 12

func _ready() -> void:
	_bind_nodes()
	_refresh_view()
	if precision_button:
		precision_button.pressed.connect(_on_precision_pressed)
	if economy_button:
		economy_button.pressed.connect(_on_economy_pressed)
	if tempo_button:
		tempo_button.pressed.connect(_on_tempo_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	GameState.currency_changed.connect(_on_currency_changed)

func _bind_nodes() -> void:
	if currency_label == null:
		currency_label = get_node_or_null("Margin/VBox/Currency")
	if info_label == null:
		info_label = get_node_or_null("Margin/VBox/Info")
	if precision_button == null:
		precision_button = get_node_or_null("Margin/VBox/PrecisionButton")
	if economy_button == null:
		economy_button = get_node_or_null("Margin/VBox/EconomyButton")
	if tempo_button == null:
		tempo_button = get_node_or_null("Margin/VBox/TempoButton")
	if continue_button == null:
		continue_button = get_node_or_null("Margin/VBox/ContinueButton")

func _on_precision_pressed() -> void:
	if not GameState.spend_currency(PRECISION_COST):
		return
	for hand_type in range(8):
		GameState.add_hand_type_upgrade(hand_type, 1, 0)
	_refresh_view("Precision Pack purchased: +1 base to all hand types.")

func _on_economy_pressed() -> void:
	if not GameState.spend_currency(ECONOMY_COST):
		return
	GameState.add_currency(6)
	GameState.add_next_round_quota_reduction(20)
	_refresh_view("Economy Pack purchased: refund + quota reduction next round.")

func _on_tempo_pressed() -> void:
	if not GameState.spend_currency(TEMPO_COST):
		return
	GameState.add_next_round_hands_bonus(1)
	GameState.add_next_round_rerolls_bonus(1)
	_refresh_view("Tempo Pack purchased: +1 hand and +1 reroll next round.")

func _on_continue_pressed() -> void:
	GameState.start_next_round()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_currency_changed(_amount: int) -> void:
	_refresh_view()

func _refresh_view(message: String = "Pick a package build for this round.") -> void:
	if currency_label:
		currency_label.text = "Currency: %d" % GameState.currency
	if precision_button:
		precision_button.text = "Buy Precision Pack (%d)" % PRECISION_COST
	if economy_button:
		economy_button.text = "Buy Economy Pack (%d)" % ECONOMY_COST
	if tempo_button:
		tempo_button.text = "Buy Tempo Pack (%d)" % TEMPO_COST
	if info_label:
		info_label.text = message
