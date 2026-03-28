# Contributing & Development Notes

## Documentation Status

- Last reviewed: 2026-03-28
- Review intent: Align wording with current architecture and event-driven conventions.


This project is organized to keep UI code separate from gameplay logic.

## Principles

1. Keep gameplay logic in `core/services` and runtime manager classes.
2. Keep scene scripts focused on presentation, input, and wiring signals.
3. Prefer data transfer through models/resources (`DiceHand`, `HandDetailsData`, etc.).
4. Use `EventBus` signals for cross-feature communication.
5. Keep `core/services` deterministic; pass gameplay state in explicitly instead of reading autoloads.
6. Treat scripts above ~150 lines as a review trigger to extract helpers or split responsibilities.

## Where to place changes

- **Scoring & hand rules:** `core/services/`
- **Round progression / run-level state:** `autoload/managers/`
- **Die and hand interaction UI:** `features/dice/`
- **Main game flow orchestration:** `scenes/main/controllers/`

## Working with `GameState`

`GameState` is the central runtime coordinator:

- Starts/reset runs.
- Starts rounds and emits round state updates.
- Applies played hand results.
- Tracks player currency and hand-type upgrades.

When adding a mechanic that affects round state, add behavior in managers first and keep `GameState` as orchestration.

## Signals and event flow

- Prefer explicit scene signals for local communication.
- Use `EventBus` for global or cross-screen events.
- Keep signal payloads model/data oriented where possible.

## Suggested workflow for new features

1. Define data shape (model/resource) if needed.
2. Add deterministic logic to a core service.
3. Integrate with manager(s) for runtime state.
4. Wire to scene/feature scripts.
5. Update docs when behavior or architecture changes.

## Anti-god-script guardrails

- If a file changes for both UI rendering and domain-rule changes, split one of those concerns out.
- If a signal has only one clear consumer, prefer a direct method call or scene-local signal.
- Prefer typed scene/controller references over `Node`, `call()`, and `has_method()` in normal gameplay flow.
- When `Dictionary` payloads start crossing multiple files, consider promoting them to a model/resource class.
