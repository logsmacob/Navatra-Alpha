extends RefCounted

## Player hand service script: coordinates this part of the game's behavior.
class_name PlayerHandService

const DIE_MATERIAL_STANDARD := "standard"
const DIE_MATERIAL_GOLDEN := "golden"
const DIE_MATERIAL_STEEL := "steel"

const MATERIAL_CURRENCY_BONUS := {
	DIE_MATERIAL_STANDARD: 0,
	DIE_MATERIAL_GOLDEN: 2,
	DIE_MATERIAL_STEEL: 1,
}

var _player_hand: Array[Dictionary] = []

func initialize(dice_count: int, face_count: int) -> void:
	_player_hand.clear()
	for _die_index in range(max(dice_count, 0)):
		var faces: Array[int] = []
		for value in range(1, max(face_count, 0) + 1):
			faces.append(value)
		_player_hand.append({
			"faces": faces,
			"material": DIE_MATERIAL_STANDARD,
		})

func get_hand_copy() -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for die_data in _player_hand:
		copy.append({
			"faces": (die_data.get("faces", []) as Array).duplicate(),
			"material": str(die_data.get("material", DIE_MATERIAL_STANDARD)),
		})
	return copy

func set_die_face_value(die_index: int, face_index: int, new_value: int) -> bool:
	if not _is_valid_die_index(die_index):
		return false
	if new_value < 1 or new_value > 6:
		return false

	var die_data := _player_hand[die_index]
	var faces: Array = die_data.get("faces", [])
	if face_index < 0 or face_index >= faces.size():
		return false

	faces[face_index] = new_value
	die_data["faces"] = faces
	_player_hand[die_index] = die_data
	return true

func set_die_material(die_index: int, material: String) -> bool:
	if not _is_valid_die_index(die_index):
		return false
	if not MATERIAL_CURRENCY_BONUS.has(material):
		return false

	var die_data := _player_hand[die_index]
	die_data["material"] = material
	_player_hand[die_index] = die_data
	return true

func get_currency_bonus_for_hand_play() -> int:
	var bonus: int = 0
	for die_data in _player_hand:
		var material := str(die_data.get("material", DIE_MATERIAL_STANDARD))
		bonus += int(MATERIAL_CURRENCY_BONUS.get(material, 0))
	return bonus

func _is_valid_die_index(die_index: int) -> bool:
	return die_index >= 0 and die_index < _player_hand.size()
