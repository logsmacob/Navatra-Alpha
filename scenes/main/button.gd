extends Button

@onready var _node : Control = $"../InfoScreen"

func _on_pressed() -> void:
	_node.visible = !_node.visible
	if _node.visible:
		z_index = 1
	else:
		z_index = 0
