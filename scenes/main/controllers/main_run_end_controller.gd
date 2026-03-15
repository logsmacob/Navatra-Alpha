extends Node
class_name MainRunEndController

var _hand: Node
var _score_bar: VBoxContainer
var _hand_type_upgrades: Control
var _win_screen: Control
var _win_stats_label: Label
var _lose_screen: Control
var _lose_stats_label: Label

func setup(
	hand: Node,
	score_bar: VBoxContainer,
	hand_type_upgrades: Control,
	win_screen: Control,
	win_stats_label: Label,
	lose_screen: Control,
	lose_stats_label: Label
) -> void:
	_hand = hand
	_score_bar = score_bar
	_hand_type_upgrades = hand_type_upgrades
	_win_screen = win_screen
	_win_stats_label = win_stats_label
	_lose_screen = lose_screen
	_lose_stats_label = lose_stats_label

func handle_run_failed(round_index: int) -> void:
	print("Run failed on round %d" % round_index)
	_hand_type_upgrades.visible = false
	if _hand != null:
		_hand.visible = false
	if _score_bar != null:
		_score_bar.visible = false
	var stats := GameState.get_run_stats()
	var lines := [
		"Defeated on Round: %d" % round_index,
		"Rounds Cleared: %d/%d" % [int(stats.get("rounds_cleared", 0)), int(stats.get("max_round", GameState.MAX_ROUNDS))],
		"Total Score: %d" % int(stats.get("total_score", 0)),
		"Hands Played: %d" % int(stats.get("total_hands_played", 0)),
		"Rerolls Used: %d" % int(stats.get("total_rerolls_used", 0)),
		"Currency Earned: %d" % int(stats.get("currency_earned", 0)),
	]
	_lose_stats_label.text = "\n".join(lines)
	_lose_screen.visible = true

func handle_run_won(round_index: int, stats: Dictionary) -> void:
	print("Run won on round %d" % round_index)
	_hand_type_upgrades.visible = false
	if _hand != null:
		_hand.visible = false
	if _score_bar != null:
		_score_bar.visible = false
	var lines := [
		"Rounds Cleared: %d/%d" % [int(stats.get("rounds_cleared", 0)), int(stats.get("max_round", GameState.MAX_ROUNDS))],
		"Total Score: %d" % int(stats.get("total_score", 0)),
		"Hands Played: %d" % int(stats.get("total_hands_played", 0)),
		"Rerolls Used: %d" % int(stats.get("total_rerolls_used", 0)),
		"Currency Earned: %d" % int(stats.get("currency_earned", 0)),
		"Currency Remaining: %d" % int(stats.get("currency_remaining", 0)),
	]
	_win_stats_label.text = "\n".join(lines)
	_win_screen.visible = true

func handle_back_to_title_pressed() -> void:
	if _hand != null:
		_hand.visible = true
	if _score_bar != null:
		_score_bar.visible = true
	_win_screen.visible = false
	_lose_screen.visible = false
	GameState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/title screen/title_screen.tscn")
