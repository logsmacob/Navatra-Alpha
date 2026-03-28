extends Node

class_name DieVisuals

@export var die: DieUI
@export var face_Texture: TextureRect
@export var material_texture: TextureButton

@export var atlas_columns: int = 4
@export var atlas_rows: int = 4

signal anim_roll_finished(die: DieUI)

var _y_tween: Tween


func _ready():
	# TextureRect uses region
	if face_Texture:
		face_Texture.region_enabled = true
	
	# TextureButton does NOT use region_enabled
	# We assume its textures are AtlasTexture already


func play_roll_animation(face_value: int, duration: float):
	await animate_roll(duration, face_value)
	anim_roll_finished.emit(die)


func animate_roll(duration: float, face: int) -> void:
	var face_index := 0

	while duration > 0:
		face_index = (face_index + 1) % (atlas_columns * atlas_rows)

		_set_atlas_frame(face_Texture, face_index)
		_set_atlas_frame(material_texture, face_index)

		await get_tree().create_timer(0.05).timeout
		duration -= 0.05

	# Final frame (face result)
	_set_atlas_frame(face_Texture, face - 1)
	_set_atlas_frame(material_texture, face - 1)


# --------------------------------------------------
# Generic atlas frame setter (supports both nodes)
# --------------------------------------------------
func _set_atlas_frame(node: Node, index: int) -> void:
	if node == null:
		return

	var atlas_tex: AtlasTexture

	# --- TextureRect ---
	if node is TextureRect:
		var tr := node as TextureRect
		if tr.texture == null:
			return
		atlas_tex = tr.texture as AtlasTexture
		if atlas_tex == null:
			return

		var region_size := atlas_tex.region.size
		if region_size == Vector2.ZERO:
			var tex_size := atlas_tex.atlas.get_size()
			region_size = Vector2(
				tex_size.x / atlas_columns,
				tex_size.y / atlas_rows
			)

		var col := index % atlas_columns
		var row := index / atlas_columns

		atlas_tex.region = Rect2(
			Vector2(col * region_size.x, row * region_size.y),
			region_size
		)

	# --- TextureButton ---
	elif node is TextureButton:
		var tb := node as TextureButton

		# Use the normal texture as AtlasTexture
		if tb.texture_normal == null:
			return

		atlas_tex = tb.texture_normal as AtlasTexture
		if atlas_tex == null:
			return

		var tex_size := atlas_tex.atlas.get_size()
		var region_size := Vector2(
			tex_size.x / atlas_columns,
			tex_size.y / atlas_rows
		)

		var col := index % atlas_columns
		var row := index / atlas_columns

		atlas_tex.region = Rect2(
			Vector2(col * region_size.x, row * region_size.y),
			region_size
		)


func _on_die_die_rolled(face: FaceData) -> void:
	_set_atlas_frame(face_Texture, face.value - 1)
	_set_atlas_frame(material_texture, face.value - 1)


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
	var target_y: float = (-die_ui.size.y * 1.1) if die_ui.is_selected else 0.0
	_tween_position_y(die_ui, target_y, 0.2)


func hover_die(die_ui: DieUI, distance: float):
	var target_y: float = distance * die_ui.size.y
	_tween_position_y(die_ui, target_y, 0.1)


func _tween_position_y(die_ui: DieUI, target_y: float, duration: float) -> void:
	if _y_tween != null and _y_tween.is_valid():
		_y_tween.kill()

	_y_tween = create_tween()
	_y_tween.tween_property(die_ui, "position:y", target_y, duration)
