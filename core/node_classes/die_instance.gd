extends Node
## Runtime die object used by gameplay and UI.
##
## `DieInstance` owns a `DieData` resource (faces) and exposes convenient setup + roll APIs.
## Use this when you need a rollable die in scene logic.
class_name DieInstance

## Emitted whenever [method roll] succeeds.
## [param face] is the face that was rolled.
signal rolled(face: FaceData)

## Resource data for this die (all available faces).
var data: DieData
## Last rolled face. `null` until the first successful roll.
var current_face: FaceData


## Creates and returns a ready-to-roll 6-sided die (1..6).
##
## This is the easiest setup path for most scenes.
static func create_standard_d6() -> DieInstance:
	var die := DieInstance.new()
	die.configure_with_sequential_faces(6)
	return die


## Initializes this die with [param face_count] faces and values 1..N.
## Returns the backing [DieData] for optional advanced customization.
func configure_with_sequential_faces(face_count: int) -> DieData:
	data = DieData.new()
	_initialize_faces(face_count)

	var sequential_values: Array[int] = []
	for i in range(face_count):
		sequential_values.append(i + 1) # dice typically start from 1

	set_face_values(sequential_values)
	return data


## Replaces each face value on the current die data.
##
## [param new_face_values] must match the current face count exactly.
## Example: after configuring 6 faces, pass an Array of size 6.
func set_face_values(new_face_values: Array[int]) -> void:
	if data == null:
		push_error("DieData has not been initialized. Call configure_with_sequential_faces first.")
		return

	if new_face_values.size() != data.faces.size():
		push_error("Face count mismatch!")
		return

	for i in range(new_face_values.size()):
		data.faces[i].face_value = new_face_values[i]


## Internal helper that creates blank [FaceData] entries.
func _initialize_faces(face_count: int) -> DieData:
	data.faces = []
	for i in range(face_count):
		data.faces.append(FaceData.new())
	return data


## Rolls the die and returns the selected [FaceData].
##
## Returns `null` if the die has not been configured.
func roll() -> FaceData:
	if data == null or data.faces.is_empty():
		push_error("DieData not configured!")
		return null

	current_face = data.faces.pick_random()
	rolled.emit(current_face)
	return current_face
