extends Control

@export var currency_label: Label
@export var hand_summary_label: Label
@export var classic_button: Button
@export var focused_button: Button
@export var brotato_button: Button

func _ready() -> void:
	_bind_nodes()
	_refresh_view()
	if classic_button:
		classic_button.pressed.connect(func() -> void:
			_open_shop("res://scenes/shop/shop.tscn")
		)
	if focused_button:
		focused_button.pressed.connect(func() -> void:
			_open_shop("res://scenes/shop/shop_focused_variant.tscn")
		)
	if brotato_button:
		brotato_button.pressed.connect(func() -> void:
			_open_shop("res://scenes/shop/shop_brotato_variant.tscn")
		)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.player_hand_changed.connect(_on_player_hand_changed)

func _bind_nodes() -> void:
	if currency_label == null:
		currency_label = get_node_or_null("Margin/VBox/Currency")
	if hand_summary_label == null:
		hand_summary_label = get_node_or_null("Margin/VBox/HandSummary")
	if classic_button == null:
		classic_button = get_node_or_null("Margin/VBox/ClassicButton")
	if focused_button == null:
		focused_button = get_node_or_null("Margin/VBox/FocusedButton")
	if brotato_button == null:
		brotato_button = get_node_or_null("Margin/VBox/BrotatoButton")

func _open_shop(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func _on_currency_changed(_amount: int) -> void:
	_refresh_view()

func _on_player_hand_changed(_hand_state: Array) -> void:
	_refresh_view()

func _refresh_view() -> void:
	if currency_label:
		currency_label.text = "Currency: %d" % GameState.currency
	var lines: Array[String] = []
	var hand := GameState.get_player_hand()
	for i in range(hand.size()):
		var die_data: Dictionary = hand[i]
		lines.append("Die %d | material=%s | faces=%s" % [
			i + 1,
			str(die_data.get("material", GameState.DIE_MATERIAL_STANDARD)),
			str(die_data.get("faces", []))
		])
	if hand_summary_label:
		hand_summary_label.text = "\n".join(lines)
