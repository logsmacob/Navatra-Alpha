extends Node

@export var animator : AnimationPlayer
@export var die : DieUI
@export var die_face_sprite : Sprite2D
@export var die_material_sprite : Sprite2D

signal anim_roll_finished(die : DieUI)

func play_roll_animation():
	animator.play("roll")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "roll":
		anim_roll_finished.emit(die)

func _on_die_die_rolled(face: FaceData) -> void:
	die_face_sprite.frame = face.value - 1

func _on_button_mouse_entered() -> void:
	die_face_sprite.position.y = 35
	die_material_sprite.position.y = 35

func _on_button_mouse_exited() -> void:
	die_face_sprite.position.y = 40
	die_material_sprite.position.y = 40

func _on_button_pressed() -> void:
	die_face_sprite.position.y = 40
	die_material_sprite.position.y = 40
	animate_die_selection(die)

func animate_die_selection(die_ui: DieUI) -> void:
	var target_y := -100 if die_ui.is_selected else 0
	var tween := create_tween()
	tween.tween_property(die_ui, "position:y", target_y, 0.2)
