# Architecture Layers (Godot 4 / GDScript)

This project uses layered scripts to keep data flow explicit and keep systems decoupled.

## Layer map

- **Data models** (`core/models`, `core/resources`)
  - `DiceHand` stores hand values without any UI dependency.
  - `FaceData`, `DieData`, and `HandDetails` represent pure data.
- **Runtime instances** (`core/node_classes`, feature runtime scripts)
  - `DieInstance` models a rollable die instance.
  - `ScoreManager` coordinates score preview/commit for one run instance.
  - `ScoreSystem` performs deterministic score math.
- **UI / presentation** (`features/**`, `scenes/**`)
  - `DieUI` is a view/controller for one die.
  - `Hand` scene emits `played_hand_ready(hand: DiceHand)` so game flow receives data models instead of UI nodes.
  - `Main` orchestrates round flow and delegates logic to runtime classes.
- **Global services** (`autoload/**`)
  - `GameState` owns singleton orchestration and delegates domain logic to services.
  - `EventBus` exposes app-wide signals only.
- **Domain services** (`core/services`)
  - `RoundProgressionService` computes per-round quota/hand/reroll setup.
  - `PlayerHandService` owns mutable player die definitions.
  - `HandScoreRulesService` provides hand score tables + upgrade-aware values.

## Ownership rules

1. UI owns visuals and input state.
2. Runtime services own gameplay logic and mutable session state.
3. Data models carry values between layers.
4. Autoloads are reserved for true singleton services.

## Communication strategy

- Prefer **signals** for cross-feature notifications (`EventBus`, scene signals).
- Use clear service APIs for direct dependencies (`ScoreManager.preview_hand`).
- Do not pass UI nodes into scoring/evaluation systems.

## Extension examples

- Add new scoring rules in `ScoreSystem` + `HandEvaluatorService` without changing UI scenes.
- Add a new screen by subscribing to `GameState.round_state_changed` and `EventBus.score_calculated`.
- Support alternate dice types by instancing different `DieData` in `DieInstance`.
