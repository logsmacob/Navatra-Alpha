# Architecture Layers (Godot 4 / GDScript)

## Documentation Status

- Last reviewed: 2026-03-28
- Review intent: Align wording with current architecture and event-driven conventions.


Navatra is structured around layered responsibilities to keep gameplay logic deterministic and UI code lightweight.

## Layer map

- **Data models & resources** (`core/models`, `core/resources`)
  - `DiceHand`: hand values independent of presentation.
  - `FaceData`, `DieData`, `HandDetailsData`: serializable gameplay data.
- **Domain services** (`core/services`)
  - `HandEvaluatorService`: detects hand types and scoring groups.
  - `HandScoreRulesService`: hand type base/mult values (upgrade-aware).
  - `RoundProgressionService`: quota/hands/reroll defaults and growth.
  - `PlayerHandService`: mutable player die configuration.
- **Runtime coordinators** (`autoload/managers`, `core/node_classes`)
  - `GameStateRunManager`: run lifecycle, round state, currency.
  - `GameStatePlayerManager`: persistent player-upgrade/hand state.
  - `ScoreManager` + `ScoreSystem`: preview/commit score math.
- **Presentation & interaction** (`features/**`, `scenes/**`)
  - `DieUI`, `Hand`, and feature scenes manage input/animation/view state.
  - `scenes/main/controllers/*` scripts orchestrate moment-to-moment gameplay flow.
- **Global singleton layer** (`autoload/**`)
  - `GameState`: top-level gameplay state coordinator and signal emitter.
  - `EventBus`: global event hub for decoupled notifications.

## Ownership rules

1. UI owns visuals, input state, and animations.
2. Services/managers own rules and mutable game session state.
3. Models/resources carry structured data between layers.
4. Autoloads stay thin and delegate rule logic to services/managers.

## Communication strategy

- Use direct method calls for clear dependencies (`ScoreManager.preview_hand`, manager APIs).
- Use scene signals for local interactions.
- Use `EventBus` for app-wide broadcasts.
- Avoid passing UI nodes into core scoring/evaluation services.

## Extension checklist

When adding a gameplay mechanic:

1. Add/update data in models/resources if needed.
2. Implement rules in a core service.
3. Integrate with `GameStateRunManager` / `GameStatePlayerManager`.
4. Expose orchestration in `GameState`.
5. Wire scene/feature scripts and signals.
6. Update docs to reflect new flow.
