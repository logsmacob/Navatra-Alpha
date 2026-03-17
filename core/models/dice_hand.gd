extends RefCounted

## Dice hand script: coordinates this part of the game's behavior.
class_name DiceHand

var values: Array[int]

func _init(initial_values: Array[int] = []) -> void:
	values = initial_values.duplicate()

func to_array() -> Array[int]:
	return values.duplicate()

func is_empty() -> bool:
	return values.is_empty()
