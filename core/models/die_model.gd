class_name DieModel
extends RefCounted

signal rolled(value: int)
signal faces_changed(new_faces: Array[int])
signal die_selected(selected: bool)

var faces: Array[int] = [1, 2, 3, 4, 5, 6]
var current_value: int = 1
var is_selected: bool = false

func select():
	is_selected = !is_selected
	die_selected.emit(is_selected)

func roll() -> int:
	if !is_selected:
		current_value = faces.pick_random()
		rolled.emit(current_value)
	return current_value

func set_all_faces(value: int):
	for i in faces.size():
		faces[i] = value
	faces_changed.emit(faces)

func set_faces(new_faces: Array[int]):
	faces = new_faces.duplicate()
	faces_changed.emit(faces)
