extends Control

@onready var hand_container = $HBoxContainer/Panel/HandContainer
@onready var hand_animator: Node = $HandAnimator
@export var die_ui_scene: PackedScene
@export var dice_per_hand: int = 5
@export var play_button: Button
@export var roll_button: Button

var is_hand_ready: bool = false
var hand_evaluator := HandEvaluatorService.new()

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

	await animator.play_hand(_get_scoring_dice())
	for die in dice:
		die.is_selected = false
	played_hand_ready.emit(_build_dice_hand())

func _get_scoring_dice() -> Array[DieUI]:
	if dice.is_empty():
		return []

	var values: Array[int] = []
	for die: DieUI in dice:
		if die.die == null or die.die.current_face == null:
			continue
		values.append(die.die.current_face.value)

	if values.size() != dice.size():
		return dice.duplicate()

	var details := hand_evaluator.get_hand_details(values)
	if details == null or details.groups.is_empty():
		return dice.duplicate()

	var counts_needed := _get_counts_needed(details)
	if counts_needed.is_empty():
		return dice.duplicate()

	var scoring_dice: Array[DieUI] = []
	for die: DieUI in dice:
		if die.die == null or die.die.current_face == null:
			continue
		var value := die.die.current_face.value
		var remaining := int(counts_needed.get(value, 0))
		if remaining > 0:
			scoring_dice.append(die)
			counts_needed[value] = remaining - 1

	if scoring_dice.is_empty():
		return dice.duplicate()

	return scoring_dice

func _get_counts_needed(details: HandDetails) -> Dictionary:
	var counts_needed := {}
	for group_data in details.groups:
		for group_name in group_data.keys():
			var group_values: Array = group_data[group_name]
			for value in group_values:
				counts_needed[value] = int(counts_needed.get(value, 0)) + 1
	return counts_needed


func _build_dice_hand() -> DiceHand:
	var values: Array[int] = []
	for die_ui in dice:
		if die_ui.die != null and die_ui.die.current_face != null:
			values.append(die_ui.die.current_face.value)
	return DiceHand.new(values)

func get_current_hand() -> DiceHand:
	return _build_dice_hand()

func _on_played_hand_finish() -> void:
	played_hand_finished.emit()

func _on_hand_animator_hand_reset_ready() -> void:
	EventBus.roll_all_dice_requested.emit()
	is_hand_ready = true
