extends Node

@export var animator : AnimationPlayer
@export var die : DieUI

signal anim_roll_finished(die : DieUI)

func play_roll_animation():
	animator.play("roll")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "roll":
		anim_roll_finished.emit(die)
