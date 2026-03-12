extends Node
class_name DieVisuals

@export var animator : AnimationPlayer
@export var die : DieUI
@export var face_sprite : Sprite2D
@export var material_sprite : Sprite2D

signal anim_roll_finished(die : DieUI)


func play_roll_animation(face_value: int, duration: float):
	await animate_roll(duration, face_value)
	anim_roll_finished.emit(die)


func animate_roll(duration: float, face: int) -> void:
	while duration > 0:
		if material_sprite.frame < 3:
			material_sprite.frame += 1
			face_sprite.frame_coords.y += 1
		else:
			material_sprite.frame = 0
			face_sprite.frame_coords.y = 0

		await get_tree().create_timer(.05).timeout
		duration -= 0.05

	material_sprite.frame = 0
	face_sprite.frame = face - 1


func _on_die_die_rolled(face: FaceData) -> void:
	face_sprite.frame_coords.x = face.value - 1

func _on_button_mouse_entered() -> void:
	if !die.is_selected:
		hover_die(die, -0.25)
	else:
		hover_die(die, -0.85)

func _on_button_mouse_exited() -> void:
	if !die.is_selected:
		hover_die(die, 0)
	else:
		hover_die(die, -1.1)

func _on_button_pressed() -> void:
	animate_die_selection(die)

func animate_die_selection(die_ui: DieUI) -> void:
	var target_y : float = (-die_ui.size.y * 1.1) if die_ui.is_selected else 0.0
	var tween := create_tween()
	tween.tween_property(die_ui, "position:y", target_y, 0.2)

func hover_die(die_ui: DieUI, distance: float):
	var target_y : float = distance * die_ui.size.y
	var tween := create_tween()
	tween.tween_property(die_ui, "position:y", target_y, 0.1)
