extends Control
## Hand script: coordinates this part of the game's behavior.

@onready var hand_container: Node = $HBoxContainer/Panel/HandContainer
@onready var hand_animator: HandAnimator = $HandAnimator
@onready var hand_scoring_selector: HandScoringSelector = $HandScoringSelector
@onready var hand_dice_pool: HandDicePool = $HandDicePool
@onready var hand_currency_bonus_service: HandCurrencyBonusService = $HandCurrencyBonusService

@export var die_ui_scene: PackedScene
@export var dice_per_hand: int = 5

var is_hand_ready: bool = false

var dice: Array[DieUI]:
	get:
		return hand_dice_pool.get_dice()

signal setup_complete
signal played_hand_ready(hand: DiceHand)
signal played_hand_finished

func _ready() -> void:
	hand_dice_pool.setup(die_ui_scene, dice_per_hand, hand_container)
	setup_complete.emit()
	is_hand_ready = true

func _on_roll_pressed() -> void:
	if not is_hand_ready:
		return

	if GameState.consume_reroll():
		roll_hand()

func roll_hand() -> void:
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
	hand_dice_pool.clear_selection()
	played_hand_ready.emit(hand_scoring_selector.build_dice_hand(dice))

func get_current_hand() -> DiceHand:
	return hand_scoring_selector.build_dice_hand(dice)

func get_scoring_material_currency_bonus() -> int:
	var scoring_dice := hand_scoring_selector.get_scoring_dice(dice)
	return hand_currency_bonus_service.get_scoring_material_currency_bonus(scoring_dice)

func _on_played_hand_finish() -> void:
	played_hand_finished.emit()

func _on_hand_reset_ready() -> void:
	roll_hand()
