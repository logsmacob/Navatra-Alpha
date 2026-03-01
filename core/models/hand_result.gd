class_name HandResult

# NOTE: Represents the evaluated result of a 5-die hand.
# `type` uses `HandEvaluatorModel.HandType` enum values.
var type: int

# NOTE: Indices of dice that contributed to the hand score/highlight.
var scoring_indices: Array[int] = []

# NOTE: Map of die value -> indices where that value appeared.
# Example: {6: [0, 2], 1: [1], 3: [3], 5: [4]}
var counts: Dictionary = {}

# NOTE: `true` only when all dice have a non-zero value and were valid for evaluation.
var is_complete: bool = false

# NOTE: Human-readable debug field for HUD/logging.
var note: String = ""
