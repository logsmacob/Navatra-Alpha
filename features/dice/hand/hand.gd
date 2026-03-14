extends Control

@onready var hand_container = $HBoxContainer/Panel/HandContainer
@onready var hand_animator: Node = $HandAnimator
@onready var hand_scoring_selector: HandScoringSelector = $HandScoringSelector
@export var die_ui_scene: PackedScene
@export var dice_per_hand: int = 5

var is_hand_ready: bool = false

signal setup_complete
signal played_hand_ready(hand: DiceHand)
signal played_hand_finished

var dice: Array[DieUI] = []

func _ready() -> void:
	_build_hand(dice_per_hand)

	setup_complete.emit()
	is_hand_ready = true

func _build_hand(dice_count: int) -> void:
	var configured_hand: Array[Dictionary] = GameState.get_player_hand()
	if configured_hand.is_empty():
		GameState.initialize_player_hand(dice_count)
		configured_hand = GameState.get_player_hand()

	for i in range(dice_count):
		var die_ui: DieUI = die_ui_scene.instantiate()
		hand_container.add_child(die_ui)

		var die := DieInstance.create_standard_d6()
		if i < configured_hand.size():
			var die_data: Dictionary = configured_hand[i]
			var faces: Array = die_data.get("faces", [])
			if faces.size() == 6:
				die.set_face_values(faces)
			die.data.material = str(die_data.get("material", GameState.DIE_MATERIAL_STANDARD))

		die_ui.set_die(die)
		die_ui.roll_if_not_selected(0)
		dice.append(die_ui)

func _on_roll_pressed() -> void:
	if not is_hand_ready:
		return
		
	if is_hand_ready and GameState.consume_reroll():
		roll_hand()

func roll_hand():
	if hand_animator.is_roll_finished:
		is_hand_ready = false
		await hand_animator.roll_hand()
		is_hand_ready = true
		EventBus.roll_all_dice_requested.emit()

func _on_play_pressed() -> void:
	if not is_hand_ready:
		return

	is_hand_ready = false
	if hand_animator == null:
		push_error("HandAnimator node is missing or has incorrect script.")
		is_hand_ready = true
		return

	await hand_animator.play_hand(hand_scoring_selector.get_scoring_dice(dice))
	for die in dice:
		die.is_selected = false
	played_hand_ready.emit(hand_scoring_selector.build_dice_hand(dice))

func get_current_hand() -> DiceHand:
	return hand_scoring_selector.build_dice_hand(dice)

func _on_played_hand_finish() -> void:
	played_hand_finished.emit()

func _on_hand_reset_ready() -> void:
	roll_hand()
