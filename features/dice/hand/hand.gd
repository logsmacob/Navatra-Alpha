extends Control

@onready var hand_container = $HBoxContainer/Panel/HandContainer
@onready var hand_animator: Node = $HandAnimator
@onready var hand_scoring_selector: HandScoringSelector = $HandScoringSelector
@export var die_ui_scene: PackedScene
@export var dice_per_hand: int = 5
@export var play_button: Button
@export var roll_button: Button

var is_hand_ready: bool = false

signal setup_complete
signal played_hand_ready(hand: DiceHand)
signal played_hand_finished

var dice: Array[DieUI] = []

func _ready() -> void:
	_build_hand(dice_per_hand)
	if not EventBus.roll_all_dice_requested.is_connected(_roll_unselected_dice):
		EventBus.roll_all_dice_requested.connect(_roll_unselected_dice)

	if roll_button != null and not roll_button.pressed.is_connected(_on_roll_pressed):
		roll_button.pressed.connect(_on_roll_pressed)
	if play_button != null and not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)
	if hand_animator != null and not hand_animator.hand_reset_ready.is_connected(_on_hand_reset_ready):
		hand_animator.hand_reset_ready.connect(_on_hand_reset_ready)
	
	setup_complete.emit()
	is_hand_ready = true

func _build_hand(dice_count: int) -> void:
	for _i in range(dice_count):
		var die_ui: DieUI = die_ui_scene.instantiate()
		hand_container.add_child(die_ui)
		die_ui.set_die(DieInstance.create_standard_d6())
		die_ui.roll_if_not_selected()
		dice.append(die_ui)

func _roll_unselected_dice() -> void:
	for die in dice:
		die.roll_if_not_selected()

func _on_roll_pressed() -> void:
	if not is_hand_ready:
		return

	if GameState.consume_reroll():
		EventBus.roll_all_dice_requested.emit()

func _on_play_pressed() -> void:
	if not is_hand_ready:
		return

	is_hand_ready = false
	var animator: HandAnimator = hand_animator as HandAnimator
	if animator == null:
		push_error("HandAnimator node is missing or has incorrect script.")
		is_hand_ready = true
		return

	await animator.play_hand(hand_scoring_selector.get_scoring_dice(dice))
	for die in dice:
		die.is_selected = false
	played_hand_ready.emit(hand_scoring_selector.build_dice_hand(dice))

func get_current_hand() -> DiceHand:
	return hand_scoring_selector.build_dice_hand(dice)

func _on_played_hand_finish() -> void:
	played_hand_finished.emit()

func _on_hand_reset_ready() -> void:
	EventBus.roll_all_dice_requested.emit()
	is_hand_ready = true
