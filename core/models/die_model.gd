class_name DieModel

signal value_changed(new_value: int)
signal hold_changed(is_held: bool)

var faces: Array[int]
var current_index: int = -1
var held: bool = false

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

func set_held(next_held: bool) -> void:
	if held == next_held:
		return
	held = next_held
	hold_changed.emit(held)

func toggle_hold() -> void:
	set_held(not held)

func is_held() -> bool:
	return held

func has_value() -> bool:
	# NOTE: `true` means the die has been rolled at least once this round.
	return current_index != -1

func reset() -> void:
	# NOTE: Round reset clears the roll state and notifies listeners.
	current_index = -1
	set_held(false)
	value_changed.emit(0)
