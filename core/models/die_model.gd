class_name DieModel

signal value_changed(new_value: int)

var faces: Array[int]
var current_index: int = -1

func _init(face_values: Array[int]) -> void:
	# NOTE: A die without faces can never roll. We keep the array empty,
	# but downstream services should handle this gracefully.
	faces = face_values.duplicate()

func roll_to(index: int) -> void:
	# NOTE: Ignore invalid indices instead of crashing game flow.
	if index < 0 or index >= faces.size():
		return
	current_index = index
	value_changed.emit(get_value())

func get_value() -> int:
	# NOTE: Value `0` is reserved for "not rolled yet".
	if current_index == -1:
		return 0
	return faces[current_index]

func get_face_count() -> int:
	return faces.size()

func has_value() -> bool:
	# NOTE: `true` means the die has been rolled at least once this round.
	return current_index != -1

func reset() -> void:
	# NOTE: Round reset clears the roll state and notifies listeners.
	current_index = -1
	value_changed.emit(0)
