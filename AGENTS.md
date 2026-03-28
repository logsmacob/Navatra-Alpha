## Documentation Status

- Last reviewed: 2026-03-28
- Review intent: Align wording with current architecture and event-driven conventions.

## Architecture Overview

This project uses a hybrid architecture:

- MVC / MVVM → separation of logic and UI
- Event-driven architecture → decoupled communication

The goal is to keep systems modular, testable, and loosely coupled.

---

## Core Principles

- UI must NOT contain game logic
- Game logic must NOT depend on UI
- Communication between systems should use signals (events)
- Avoid tight coupling between nodes

---

## Layer Responsibilities

### Model (Data / State)
- Holds game data and state
- No knowledge of UI
- No direct node dependencies

Examples:
- Round quota, hands remaining, and rerolls in `GameState`
- Player currency and owned trinkets/upgrades in run/player managers
- Hand evaluation inputs/outputs (`DiceHand`, scoring context)

---

### View (UI)
- Displays data to the player
- Handles visual updates only
- Must NOT contain gameplay logic

Examples:
- `ui/hud/hud.tscn` and HUD labels/bars
- `features/score_bar` visual score and quota display
- `scenes/shop/shop.tscn` item list and button visuals

---

### ViewModel / Controller (Glue Layer)
- Connects Model and View
- Transforms data for UI
- Listens to events and updates UI

Examples:
- `scenes/main/controllers/main_round_flow_controller.gd`
- `scenes/main/controllers/main_gameplay_controller.gd`
- `features/score_bar/controllers/*` bridging score data to UI

---

## Event-Driven Rules

- Use signals for communication between systems
- Avoid direct method calls across systems
- Systems should emit events instead of calling each other

### Example

```gdscript
# BAD (tight coupling)
GameStateRunManager.submit_hand(dice_values)
$HUD/QuotaLabel.text = str(GameState.run.quota_remaining)

# GOOD (event-driven)
EventBus.emit_signal("hand_submitted", dice_values)
# HUD/score bar listen to EventBus/GameState signals and refresh themselves.
```

---

## Documentation Maintenance

- When gameplay flow changes, update `docs/architecture/event_flow.md` in the same PR.
- When layer ownership changes, update `docs/architecture/layers.md` and `docs/development/contributing.md`.
- Keep examples controller/service-first and event-driven.

---

## Agent Change Checklist

When making project changes, review and apply guidance from:

- `docs/development/godot_large_project_best_practices.md`

Priority focus while implementing changes:

- Keep UI scripts presentation-only and signal-emitting
- Route gameplay updates through controllers/services/model layers
- Favor signal/event-driven communication over direct cross-system calls
- Preserve loose coupling and modular feature boundaries
