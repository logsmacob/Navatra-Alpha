extends Node

# NOTE: Global signal hub for decoupled feature communication.

# Emitted when any system requests a full dice roll.
@warning_ignore("unused_signal")
signal roll_all_dice_requested

@warning_ignore("unused_signal")
signal roll_die(die_ui : DieUI)

@warning_ignore("unused_signal")
signal select_die(die_ui : DieUI)

# Emitted when a hand has been evaluated into details (type + scoring groups).
@warning_ignore("unused_signal")
signal hand_evaluated(details: HandDetails)

# Emitted after score preview is calculated for a hand.
@warning_ignore("unused_signal")
signal score_calculated(details: HandDetails, type_total: int, breakdown: Dictionary)

# Emitted when a played hand's round score is applied.
@warning_ignore("unused_signal")
signal round_score_applied(score: int)

# Emitted when score manager commits cumulative run score.
@warning_ignore("unused_signal")
signal score_committed(total_score: int)
