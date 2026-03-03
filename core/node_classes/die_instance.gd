extends Node
class_name DieInstance

@export var data: DieData
var current_face: FaceData

func roll() -> FaceData:
	if data == null or data.faces.is_empty():
		push_error("DieData not configured!")
		return null
	
	current_face = data.faces.pick_random()
	return current_face
