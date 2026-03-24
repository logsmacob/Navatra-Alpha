# Project Review — Navatra

Date: 2026-03-24
Reviewer: Codex

## Implementation update (2026-03-24)

Applied now (low-risk slice):
- Replaced global reroll refresh wiring (`EventBus.roll_all_dice_requested`) with hand-local signals:
  - `Hand.roll_requested` for reroll intent
  - `Hand.roll_completed` for post-roll preview/state refresh
- Moved reroll consumption orchestration from `Hand` into `MainGameplayController`.

Deferred (recommended to batch in later PRs):
- Shop flow controller extraction.
- Shop purchase service contract typing cleanup.
- Test harness/CI additions.

## Scope and method

This review covered repository structure, architecture docs, and representative gameplay/runtime scripts across autoloads, controllers, features, and shop flow.

Primary files inspected:
- `README.md`
- `docs/architecture/layers.md`
- `docs/architecture/event_flow.md`
- `autoload/game_state.gd`
- `autoload/managers/game_state_run_manager.gd`
- `autoload/managers/game_state_player_manager.gd`
- `scenes/main/main.gd`
- `scenes/main/controllers/main_gameplay_controller.gd`
- `scenes/main/controllers/main_round_flow_controller.gd`
- `features/dice/hand/hand.gd`
- `scenes/shop/shop.gd`
- `core/services/shop_purchase_service.gd`

---

## Executive summary

Navatra has a strong architectural base: clear layer docs, dedicated run/player managers, and a mostly clean main-scene controller split. The biggest opportunity is consistency with your own architecture rule set: some UI scripts currently own gameplay/rule decisions that should be moved into controller/service layers.

Overall status: **good foundation with medium-priority refactors recommended**.

---

## What is working well

1. **Clear architecture documentation and intent**
   - The layering and responsibility boundaries are explicit in docs and largely reflected in code.

2. **State ownership is centralized in GameState managers**
   - Round/currency/run lifecycle and player modifiers are delegated to `GameStateRunManager` and `GameStatePlayerManager`, which keeps rule logic out of most UI code.

3. **Main gameplay orchestration is already controller-first**
   - `MainGameplayController` handles the play-resolution chain and score-bar orchestration, which is the correct direction for long-term maintainability.

4. **Event-driven gameplay flow is documented**
   - The event-flow doc makes the longest signal chain tractable and easier to debug when extending the play/reset sequence.

---

## Findings and recommendations

### 1) Architecture drift: gameplay decisions inside UI scripts (medium)

Your project principles say UI should be visual-only, but a few UI nodes currently perform gameplay/rule orchestration directly.

Examples:
- `Shop` directly starts next round and performs purchase attempts via runtime services in scene script handlers.
- `Hand` still owns part of local gameplay flow sequencing (animation/reset/input gating), though reroll resource consumption has been moved to the gameplay controller.

Why it matters:
- Makes feature nodes harder to reuse and unit-test.
- Increases coupling to singletons in view scripts.
- Complicates future refactors (e.g., alternate game modes/UI variants).

Recommendation:
- Introduce/expand controllers for `Hand` and `Shop` scene flows so view scripts emit intent signals only (e.g., `roll_requested`, `play_requested`, `buy_offer_requested`, `continue_requested`).
- Keep rule application in controller/service layers; keep view scripts focused on visuals and local interaction state.

### 2) Global-event scope improved for reroll refresh (resolved in current slice)

Reroll refresh now uses hand-local signals, which improves traceability and reduces hidden global coupling for this flow.

Follow-up recommendation:
- Continue this principle for future local-only interactions; keep `EventBus` reserved for app-wide broadcasts.

### 3) Service boundary consistency in shop purchase path (low)

`ShopPurchaseService.apply_purchase` uses dynamic `has_method`/`call` checks against a generic `Node` game state object.

Why it matters:
- Reduces static clarity and discoverability.
- Makes refactors riskier (method rename issues are runtime-only).

Recommendation:
- Type this service to a dedicated interface or `GameState` contract wrapper (even a thin adapter) to keep compile-time/editor guidance stronger.

### 4) Test coverage gap (medium)

No automated tests or smoke checks are present in the repository.

Why it matters:
- Signal ordering regressions and round-progression edge cases can slip in silently.
- Upgrade/modifier interactions are difficult to validate manually over time.

Recommendation:
- Add a minimal test harness first for pure services/managers:
  - `RoundProgressionService`
  - `GameStateRunManager`
  - `HandEvaluatorService`
  - `ShopOfferService` and purchase modifier application
- Prioritize deterministic input/output tests before scene-level tests.

---

## Suggested phased plan

### Phase 1 (quick wins)
- Add a small `ShopController` and shift purchase/continue-round orchestration out of `shop.gd`.
- Expand hand intent-signal pattern further for play flow orchestration as needed.

### Phase 2 (stability)
- Replace dynamic purchase service calls with typed contract/adaptor.

### Phase 3 (quality gates)
- Add baseline automated tests for managers/services.
- Add CI command to run script checks/tests before merge.

---

## Conclusion

The project is in a healthy place architecturally and already demonstrates good separation in many critical paths. The top improvement is **enforcing your own layer rules consistently in `Hand` and `Shop` scene scripts** so UI remains presentation-first while controllers/services own gameplay decisions.
