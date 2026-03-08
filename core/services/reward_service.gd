extends RefCounted
class_name RewardService

var _reward_pool: Array[RewardDefinition] = []

func _init() -> void:
	_build_default_reward_pool()

func generate_rewards(count: int) -> Array[RewardDefinition]:
	if _reward_pool.is_empty() or count <= 0:
		return []

	var available_rewards: Array[RewardDefinition] = _reward_pool.duplicate()
	available_rewards.shuffle()

	var picked_rewards: Array[RewardDefinition] = []
	var pick_count: int = mini(count, available_rewards.size())
	for i in range(pick_count):
		picked_rewards.append(available_rewards[i])

	return picked_rewards

func apply_reward(reward: RewardDefinition, game_state: Node) -> void:
	if reward == null or game_state == null:
		return

	match reward.type:
		RewardDefinition.RewardType.ADD_HAND:
			game_state.hands_remaining += int(reward.value)
		RewardDefinition.RewardType.ADD_REROLL:
			game_state.rerolls_remaining += int(reward.value)
		RewardDefinition.RewardType.ADD_SCORE:
			game_state.apply_score_to_quota(int(reward.value))
		RewardDefinition.RewardType.SCORE_MULT:
			game_state.round_score_multiplier += reward.value

	if game_state.has_method("_emit_round_state"):
		game_state.call("_emit_round_state")

func _build_default_reward_pool() -> void:
	_reward_pool.clear()
	_reward_pool.append(_create_reward(
		"add_hand",
		"Tactical Reserve",
		"+1 hand this round.",
		RewardDefinition.RewardType.ADD_HAND,
		1.0
	))
	_reward_pool.append(_create_reward(
		"add_reroll",
		"Lucky Shift",
		"+1 reroll this round.",
		RewardDefinition.RewardType.ADD_REROLL,
		1.0
	))
	_reward_pool.append(_create_reward(
		"add_score",
		"Quota Relief",
		"Reduce current quota by 50 immediately.",
		RewardDefinition.RewardType.ADD_SCORE,
		50.0
	))
	_reward_pool.append(_create_reward(
		"score_mult",
		"Momentum",
		"+10% score multiplier for this round.",
		RewardDefinition.RewardType.SCORE_MULT,
		0.1
	))

func _create_reward(reward_id: String, reward_title: String, reward_description: String, reward_type: RewardDefinition.RewardType, reward_value: float) -> RewardDefinition:
	var reward := RewardDefinition.new()
	reward.id = reward_id
	reward.title = reward_title
	reward.description = reward_description
	reward.type = reward_type
	reward.value = reward_value
	return reward
