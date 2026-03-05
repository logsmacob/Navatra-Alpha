extends Control

@onready var hand: Control = $MarginContainer/Hand

func _ready() -> void:
	hand.played_hand_ready.connect(_on_played_hand_ready)
	GameState.round_started.connect(_on_round_started)
	GameState.round_completed.connect(_on_round_completed)
	GameState.run_failed.connect(_on_run_failed)
	GameState.round_state_changed.connect(_on_round_state_changed)

func _on_played_hand_ready(dice: Array[DieUI]) -> void:
	var score := _calculate_hand_score(dice)
	GameState.apply_score_to_quota(score)
	GameState.consume_hand()
	hand._on_played_hand_finish()

func _calculate_hand_score(dice: Array[DieUI]) -> int:
	var total := 0
	for die in dice:
		if die.die != null and die.die.current_face != null:
			total += die.die.current_face.value
	return total

func _on_round_started(round_index: int, quota: int, hands: int, rerolls: int) -> void:
	print("Round %d started | quota=%d hands=%d rerolls=%d" % [round_index, quota, hands, rerolls])

func _on_round_completed(round_index: int) -> void:
	print("Round %d complete" % round_index)
	GameState.start_next_round()

func _on_run_failed(round_index: int) -> void:
	print("Run failed on round %d" % round_index)

func _on_round_state_changed(state: Dictionary) -> void:
	print("State: ", state)
