extends Node

## Hand dice pool script: coordinates this part of the game's behavior.
class_name HandDicePool

signal hand_built(dice: Array[DieUI])
signal die_created(index: int, die_ui: DieUI, die: DieInstance)

var _dice: Array[DieUI] = []

func setup(die_ui_scene: PackedScene, dice_per_hand: int, hand_container: Node) -> void:
	_dice.clear()
	var configured_hand := _get_or_create_player_hand(dice_per_hand)

	for i in range(dice_per_hand):
		var die_ui: DieUI = die_ui_scene.instantiate()
		hand_container.add_child(die_ui)

		var die := _build_die_from_config(configured_hand, i)
		die_ui.set_die(die)
		die_ui.roll_if_not_selected(0)

		_dice.append(die_ui)
		die_created.emit(i, die_ui, die)

	hand_built.emit(_dice)

func get_dice() -> Array[DieUI]:
	return _dice

func clear_selection() -> void:
	for die in _dice:
		die.is_selected = false

func _get_or_create_player_hand(dice_per_hand: int) -> Array[Dictionary]:
	var configured_hand: Array[Dictionary] = GameState.get_player_hand()
	if configured_hand.is_empty():
		GameState.initialize_player_hand(dice_per_hand)
		configured_hand = GameState.get_player_hand()
	return configured_hand

func _build_die_from_config(configured_hand: Array[Dictionary], index: int) -> DieInstance:
	var die := DieInstance.create_standard_d6()
	if index >= configured_hand.size():
		return die

	var die_data: Dictionary = configured_hand[index]
	var faces: Array = die_data.get("faces", [])
	if faces.size() == 6:
		die.set_face_values(faces)
	die.data.material = str(die_data.get("material", GameState.DIE_MATERIAL_STANDARD))
	return die
