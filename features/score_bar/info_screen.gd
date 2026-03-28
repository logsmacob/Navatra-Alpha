extends Control
class_name InfoScreen

const GENERAL_MODIFIER_ROWS := ModifierSchema.GENERAL_MODIFIER_ROWS

@export var general_modifiers_label: Label

func _ready() -> void:
	pass

func update_general_modifiers(modifiers: Dictionary) -> void:
	if general_modifiers_label == null:
		return
	general_modifiers_label.text = _build_general_modifier_text(modifiers)

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = ["General Modifiers:"]
	for row in GENERAL_MODIFIER_ROWS:
		var value := int(modifiers.get(row.key, 0))
		lines.append("- %s" % _format_general_modifier_line(str(row.key), str(row.label), value))
	return "\n".join(lines)

func _format_signed_modifier(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return "%d" % value

func _format_general_modifier_line(key: String, label: String, value: int) -> String:
	var signed_value := _format_signed_modifier(value)
	if key.begins_with("base_") and key.ends_with("_value"):
		return "%s %s Base" % [label, signed_value]
	if key.begins_with("mult_") and key.ends_with("_value"):
		return "%s %s Mult" % [label, signed_value]
	return "%s %s" % [label, signed_value]
