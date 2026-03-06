extends RefCounted
class_name HandDetails

var type: int
var groups: Array

func _init(hand_type: int = 0, hand_groups: Array = []) -> void:
	type = hand_type
	groups = hand_groups
