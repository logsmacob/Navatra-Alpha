# Best Practices Alignment Review — 2026-03-28

Reference: `res://docs/development/godot_large_project_best_practices.md`

## Summary

Overall, the project is already moving in the right direction for a large Godot codebase:

- Feature-oriented structure is in place (`features/`, `core/`, `scenes/`).
- Controllers/services are present and doing significant orchestration work.
- Signals are used in key gameplay flows (`main.gd` wiring, shop intent signals).

Biggest opportunity areas are **completing UI/logic separation** and **reducing singleton coupling** in feature scripts.

## What is already aligned

1. **Feature-based organization exists**
   - You already group by domain/feature (`features/dice`, `features/score_bar`, `scenes/shop/controllers`, etc.).

2. **Signal-driven scene orchestration is strong**
   - `scenes/main/main.gd` wires hand/game-state events and routes them into controllers.
   - `scenes/shop/shop.gd` behaves as a view that emits purchase/reroll/continue intents.

3. **Service/model separation exists for gameplay logic**
   - Scoring and progression logic are largely in `core/services/*` and models/resources.

## Gaps to close for closer alignment

### 1) UI scripts that still read global game state directly

Best-practices target: UI should be presentation-only and receive already-prepared data.

- `features/score_bar/corner_label.gd` previously read `GameState` directly in `_ready`.
- This has now been removed so state now comes through the score-bar controller path.

### 2) Controllers still depend heavily on global singletons

Best-practices target: prefer explicit dependencies (injected references/services) over hidden globals where practical.

Current pattern in places like `main_gameplay_controller.gd` and `main_round_flow_controller.gd`:

- Direct calls to `GameState.*` for mutations.
- Mixed flow of local scene refs + global autoload access.

This is acceptable short-term, but long-term it makes isolated testing and refactors harder.

### 3) EventBus usage is partial

Best-practices target: shared/cross-feature communication through signal buses (or well-bounded domain signals), not direct cross-calls.

- There is EventBus usage, but some cross-feature behavior still routes through direct controller-to-singleton methods.
- Standardizing event names/payloads for major gameplay transitions would improve decoupling.

## Recommended action plan (priority order)

## P0 (quick wins, low risk)

1. **Keep UI scripts state-agnostic**
   - Rule: no `GameState` reads/writes in scripts that `extends Control`/`PanelContainer` (except intentionally thin root composition scripts).
   - Add this as a checklist item in PR reviews.

2. **Adopt a UI intent naming standard**
   - For view-emitted signals, use verb + `_requested` consistently.
   - Example: `play_requested`, `reroll_requested`, `offer_purchase_requested`.

3. **Standardize one source of truth for HUD refresh**
   - Refresh HUD only from `GameState`/EventBus signals instead of ad-hoc manual refresh calls when possible.

## P1 (structural improvements)

1. **Introduce state/application ports for controllers**
   - Create interfaces/ports (like `ShopTransactionPort`) for frequently-used `GameState` operations in gameplay controllers.
   - Inject these into controllers in `main.gd` setup.

2. **Promote gameplay transitions to explicit events**
   - Define and document event payloads for key transitions:
     - hand submitted / resolved
     - reroll consumed
     - reward phase entered
     - round completed

3. **Document event ownership per feature**
   - Extend `docs/architecture/event_flow.md` with a producer/consumer table.

## P2 (quality and scaling)

1. **Add script-role lint checklist**
   - UI script: no domain mutation.
   - Controller: orchestration only.
   - Service/model: deterministic logic/state.

2. **Create smoke tests around controller flows**
   - Prioritize `main_gameplay_controller` and `shop_controller` with fake ports/services.

3. **Converge naming/paths over time**
   - Keep snake_case paths and ensure class names map clearly to feature ownership.

## Concrete next PR ideas

- PR 1: Extract a `RunStatePort` used by `MainGameplayController` and `MainRoundFlowController`.
- PR 2: Add event payload contracts to `docs/architecture/event_flow.md`.
- PR 3: Add a lightweight contributor checklist section to `docs/development/contributing.md` enforcing UI script boundaries.

## Notes

This review intentionally favors incremental changes over large rewrites so you can keep shipping while steadily improving architecture.
