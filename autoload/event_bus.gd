extends Node

# NOTE: Global signal hub for decoupled feature communication.

# Emitted when any system requests a full dice roll.
signal roll_all_dice_requested

# Emitted after hand evaluation is complete.
signal dice_evaluated(result: HandResult)
