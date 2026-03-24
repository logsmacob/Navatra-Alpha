extends Node

## Die animator script: coordinates this part of the game's behavior.
class_name DieVisuals

@export var animator : AnimationPlayer
@export var die : DieUI
@export var face_sprite : Sprite2D
@export var material_sprite : Sprite2D

signal anim_roll_finished(die : DieUI)

var _y_tween: Tween

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
	if die == null or not die.is_interaction_enabled:
		return
	if !die.is_selected:
		hover_die(die, -0.25)
	else:
		hover_die(die, -0.85)

func _on_button_mouse_exited() -> void:
	if die == null or not die.is_interaction_enabled:
		return
	if !die.is_selected:
		hover_die(die, 0)
	else:
		hover_die(die, -1.1)

func _on_button_pressed() -> void:
	if die == null or not die.is_interaction_enabled:
		return
	animate_die_selection(die)

func animate_die_selection(die_ui: DieUI) -> void:
	var target_y : float = (-die_ui.size.y * 1.1) if die_ui.is_selected else 0.0
	_tween_position_y(die_ui, target_y, 0.2)

func hover_die(die_ui: DieUI, distance: float):
	var target_y : float = distance * die_ui.size.y
	_tween_position_y(die_ui, target_y, 0.1)

func _tween_position_y(die_ui: DieUI, target_y: float, duration: float) -> void:
	if _y_tween != null and _y_tween.is_valid():
		_y_tween.kill()
	_y_tween = create_tween()
	_y_tween.tween_property(die_ui, "position:y", target_y, duration)
