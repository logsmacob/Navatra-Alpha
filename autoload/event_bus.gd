extends Node

# NOTE: Global signal hub for decoupled feature communication.

# Emitted when any system requests a full dice roll.
@warning_ignore("unused_signal")
signal roll_all_dice_requested
