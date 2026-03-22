extends Control
## Score bar script: coordinates this part of the game's behavior.
class_name ScoreBar

const GENERAL_MODIFIER_ROWS := [
	{"key": "luck", "label": "Luck"},
	{"key": "base_marbles_per_round", "label": "Base Marbles per Round"},
	{"key": "shop_rerolls", "label": "Re-Rolls"},
	{"key": "shop_playable_hands", "label": "Playable Hands"},
	{"key": "base_1_value", "label": "Base 1 Value"},
	{"key": "base_2_value", "label": "Base 2 Value"},
	{"key": "base_3_value", "label": "Base 3 Value"},
	{"key": "base_4_value", "label": "Base 4 Value"},
	{"key": "base_5_value", "label": "Base 5 Value"},
	{"key": "base_6_value", "label": "Base 6 Value"},
]

@export var round_index_label: Label
@export var quota_label: Label 
@export var marble_label: Label
@export var current_hand_points_label: Label 
@export var hand_type_label: Label 
@export var hand_type_value_label: Label 
@export var hand_type_base_label: Label 
@export var hand_type_mult_label: Label 
@export var current_hand_points_label_math: Label 
@export var general_modifiers_label: Label 

var score_manager: ScoreManager

func _ready() -> void:
	score_manager = ScoreManager.new()
	add_child(score_manager)

func set_scoring_context(context: HandScoringContext) -> void:
	if score_manager == null:
		return
	score_manager.set_scoring_context(context)

func preview_hand(hand_data: DiceHand) -> void:
	if hand_data == null or score_manager == null:
		return

	set_scoring_context(_build_scoring_context())
	score_manager.preview_hand(hand_data.to_array())

func can_play_previewed_hand() -> bool:
	return score_manager != null and score_manager.can_play_hand()

func play_previewed_hand() -> Dictionary:
	if score_manager == null or not score_manager.can_play_hand():
		return {
			"played": false,
			"hand_name": "Unknown",
			"applied_score": 0,
		}

	score_manager.play_hand()
	var played_hand_name := _get_played_hand_name()
	var applied_score := score_manager.commit_played_hand()

	return {
		"played": true,
		"hand_name": played_hand_name,
		"applied_score": applied_score,
	}

func update_state(state: Dictionary = {}) -> void:
	if score_manager == null:
		return

	if state.is_empty():
		state = GameState.get_round_state()

	var breakdown := score_manager.get_last_breakdown()

	round_index_label.text = "Round %d/%d" % [int(state.get("round_index", 0)), GameState.MAX_ROUNDS]
	quota_label.text = "%d" % int(state.get("quota_remaining", 0))
	marble_label.text = "Marbles: %d" % int(state.get("currency", 0))

	if not breakdown.is_empty():
		var hand_name := str(breakdown.get("hand_name", "-"))
		var type_total := int(breakdown.get("type_total", 0))
		var final_score := int(breakdown.get("final_score", 0))
		current_hand_points_label.text = "Current Hand Points: %d" % final_score
		current_hand_points_label_math.text = "(Base %d + Dice %d) x Mult %d = %d" % [
			int(breakdown.get("base", 0)),
			int(breakdown.get("group_total", 0)),
			int(breakdown.get("mult", 0)),
			final_score,
		]
		hand_type_base_label.text = "Base %d" % [int(breakdown.get("base", 0))]
		hand_type_mult_label.text = "Mult X %d" % [int(breakdown.get("mult", 0))]
		hand_type_label.text = "%s:" % hand_name
		hand_type_value_label.text = "= -%d" % type_total

	general_modifiers_label.text = _build_general_modifier_text(GameState.get_general_modifiers())

func _get_played_hand_name() -> String:
	var breakdown := score_manager.get_last_breakdown()
	return str(breakdown.get("hand_name", "Unknown"))

func _build_scoring_context() -> HandScoringContext:
	return HandScoringContext.new(GameState.hand_type_upgrades, GameState.round_score_multiplier)

func _build_general_modifier_text(modifiers: Dictionary) -> String:
	var lines: Array[String] = ["General Modifiers:"]
	for row in GENERAL_MODIFIER_ROWS:
		lines.append("- %s: %d" % [str(row.label), int(modifiers.get(row.key, 0))])
	return "\n".join(lines)
