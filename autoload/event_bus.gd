extends Node

# NOTE: Global signal hub for decoupled feature communication.

# Emitted when any system requests a full dice roll.
signal roll_all_dice_requested

# Emitted after hand evaluation is complete.
signal dice_evaluated(result: HandResult)

# Emitted when a run is initialized.
signal run_started(round_state: RoundStateModel)

# Emitted when a new round starts.
signal round_started(round_state: RoundStateModel)

# Emitted whenever hands/rerolls/quota values change.
signal round_state_changed(round_state: RoundStateModel)

# Emitted after a scored hand is submitted.
signal hand_scored(score: int, quota_remaining: int)

# Emitted when player clears the current quota.
signal round_cleared(round_state: RoundStateModel)

# Emitted when no playable hands remain and quota is still positive.
signal run_failed(round_state: RoundStateModel)

# Emitted when a trinket is added to the run.
signal trinket_added(trinket: TrinketModel)
