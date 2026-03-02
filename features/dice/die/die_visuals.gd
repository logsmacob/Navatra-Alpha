extends Node

@export var sprite = Sprite2D
@export var anime = AnimationPlayer

func show_value(value: int):
	sprite.frame = value - 1

func show_selected(is_selected):
	if is_selected:
		sprite.modulate = Color.DIM_GRAY
	else:
		sprite.modulate = Color.WHITE
