extends Node2D

# NOTE: Pure visual binding for one die model.
var model: DieModel

func bind(die_model: DieModel) -> void:
	model = die_model
	model.value_changed.connect(_on_value_changed)

func _on_value_changed(value: int) -> void:
	# NOTE: Placeholder for sprite frame / label updates.
	# Convention: 0 means "unrolled" visual state.
	pass
