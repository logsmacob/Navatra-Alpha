class_name ModifierSchema
extends RefCounted

const DEFAULT_GENERAL_MODIFIERS := {
	"luck": 0,
	"base_marbles_per_round": 0,
	"shop_rerolls": 3,
	"shop_playable_hands": 3,
	"face_1_to": 1,
	"face_2_to": 2,
	"face_3_to": 3,
	"face_4_to": 4,
	"face_5_to": 5,
	"face_6_to": 6,
	"base_1_value": 1,
	"base_2_value": 2,
	"base_3_value": 3,
	"base_4_value": 4,
	"base_5_value": 5,
	"base_6_value": 6,
	"mult_1_value": 0,
	"mult_2_value": 0,
	"mult_3_value": 0,
	"mult_4_value": 0,
	"mult_5_value": 0,
	"mult_6_value": 0,
}

const GENERAL_MODIFIER_ROWS := [
	{"key": "luck", "label": "Luck"},
	{"key": "base_marbles_per_round", "label": "Base Marbles per Round"},
	{"key": "shop_rerolls", "label": "Re-Rolls"},
	{"key": "shop_playable_hands", "label": "Playable Hands"},
	{"key": "face_1_to", "label": "Face [1] Result"},
	{"key": "face_2_to", "label": "Face [2] Result"},
	{"key": "face_3_to", "label": "Face [3] Result"},
	{"key": "face_4_to", "label": "Face [4] Result"},
	{"key": "face_5_to", "label": "Face [5] Result"},
	{"key": "face_6_to", "label": "Face [6] Result"},
	{"key": "base_1_value", "label": "Face Value [1]"},
	{"key": "base_2_value", "label": "Face Value [2]"},
	{"key": "base_3_value", "label": "Face Value [3]"},
	{"key": "base_4_value", "label": "Face Value [4]"},
	{"key": "base_5_value", "label": "Face Value [5]"},
	{"key": "base_6_value", "label": "Face Value [6]"},
	{"key": "mult_1_value", "label": "Face Value [1]"},
	{"key": "mult_2_value", "label": "Face Value [2]"},
	{"key": "mult_3_value", "label": "Face Value [3]"},
	{"key": "mult_4_value", "label": "Face Value [4]"},
	{"key": "mult_5_value", "label": "Face Value [5]"},
	{"key": "mult_6_value", "label": "Face Value [6]"},
]

const GENERAL_MODIFIER_LABELS := {
	"luck": "Luck",
	"base_marbles_per_round": "Base Marbles per Round",
	"shop_rerolls": "Re-Rolls",
	"shop_playable_hands": "Playable Hands",
	"face_1_to": "Face [1] Result",
	"face_2_to": "Face [2] Result",
	"face_3_to": "Face [3] Result",
	"face_4_to": "Face [4] Result",
	"face_5_to": "Face [5] Result",
	"face_6_to": "Face [6] Result",
	"base_1_value": "Face Value [1]",
	"base_2_value": "Face Value [2]",
	"base_3_value": "Face Value [3]",
	"base_4_value": "Face Value [4]",
	"base_5_value": "Face Value [5]",
	"base_6_value": "Face Value [6]",
	"mult_1_value": "Face Value [1]",
	"mult_2_value": "Face Value [2]",
	"mult_3_value": "Face Value [3]",
	"mult_4_value": "Face Value [4]",
	"mult_5_value": "Face Value [5]",
	"mult_6_value": "Face Value [6]",
}

static func get_general_modifier_keys() -> Array[String]:
	var keys: Array[String] = []
	for row in GENERAL_MODIFIER_ROWS:
		keys.append(str(row.get("key", "")))
	return keys
