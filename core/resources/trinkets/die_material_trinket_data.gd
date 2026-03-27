class_name DieMaterialTrinketData
extends TrinketData

@export_group("Die Material Variant")
@export var selected_die_index: int = 0
@export var target_material: String = "marble"
@export_range(0, 999, 1) var marbles_per_matching_die: int = 1
@export var grant_only_when_material_scored: bool = true

func apply_purchase_effects(game_state: Node) -> void:
	if game_state == null:
		return
	if game_state.has_method("set_die_material"):
		game_state.call("set_die_material", max(selected_die_index, 0), target_material)

func get_runtime_scoring_bonus(play_context: Dictionary) -> Dictionary:
	var materials: Array = play_context.get("scoring_die_materials", [])
	if materials.is_empty():
		return {"base": base, "mult": mult, "currency": 0}

	var matching_count := 0
	for material in materials:
		if material == target_material:
			matching_count += 1

	if grant_only_when_material_scored and matching_count <= 0:
		return {"base": 0, "mult": 0, "currency": 0}

	return {
		"base": base,
		"mult": mult,
		"currency": matching_count * marbles_per_matching_die,
	}

func get_display_description() -> String:
	var description := super.get_display_description()
	var extra := "Converts die #%d to %s. +%d marbles per scoring %s die." % [
		max(selected_die_index, 0) + 1,
		target_material,
		marbles_per_matching_die,
		target_material,
	]
	if description == "No effect":
		return extra
	return "%s\n%s" % [description, extra]

# Backward-compatible alias for older callers and scenes.
func get_display_discription() -> String:
	return get_display_description()
