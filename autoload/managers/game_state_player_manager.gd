extends RefCounted

## Game state player manager script: coordinates this part of the game's behavior.
class_name GameStatePlayerManager

const DIE_MATERIAL_STANDARD := PlayerHandService.DIE_MATERIAL_STANDARD
const DIE_MATERIAL_GOLDEN := PlayerHandService.DIE_MATERIAL_GOLDEN
const DIE_MATERIAL_STEEL := PlayerHandService.DIE_MATERIAL_STEEL
const MATERIAL_CURRENCY_BONUS := PlayerHandService.MATERIAL_CURRENCY_BONUS

var hand_type_upgrades: Dictionary = {}
var shop_item_counts: Dictionary = {}

var _player_hand_service: PlayerHandService = PlayerHandService.new()

func initialize_player_hand(dice_count: int, face_count: int) -> void:
	_player_hand_service.initialize(dice_count, face_count)

func get_player_hand() -> Array[Dictionary]:
	return _player_hand_service.get_hand_copy()

func set_die_face_value(die_index: int, face_index: int, new_value: int) -> bool:
	return _player_hand_service.set_die_face_value(die_index, face_index, new_value)

func set_die_material(die_index: int, material: String) -> bool:
	return _player_hand_service.set_die_material(die_index, material)

func get_currency_bonus_for_hand_play() -> int:
	return _player_hand_service.get_currency_bonus_for_hand_play()

func clear_hand_type_upgrades() -> void:
	hand_type_upgrades.clear()

func add_hand_type_upgrade(hand_type: int, base_bonus: int, mult_bonus: int) -> void:
	if not hand_type_upgrades.has(hand_type):
		hand_type_upgrades[hand_type] = {"base": 0, "mult": 0}

	var upgrade_data: Dictionary = hand_type_upgrades[hand_type]
	upgrade_data["base"] = int(upgrade_data.get("base", 0)) + max(base_bonus, 0)
	upgrade_data["mult"] = int(upgrade_data.get("mult", 0)) + max(mult_bonus, 0)
	hand_type_upgrades[hand_type] = upgrade_data

func get_hand_type_upgrade(hand_type: int) -> Dictionary:
	if not hand_type_upgrades.has(hand_type):
		return {"base": 0, "mult": 0}
	return hand_type_upgrades[hand_type].duplicate()

func clear_shop_items() -> void:
	shop_item_counts.clear()

func add_shop_item(item_id: String) -> void:
	shop_item_counts[item_id] = int(shop_item_counts.get(item_id, 0)) + 1

func get_shop_item_counts() -> Dictionary:
	return shop_item_counts.duplicate()
