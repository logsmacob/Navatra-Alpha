# Shop Trinket Data Type Review (2026-03-27)

## Scope

Reviewed:
- `core/resources/trinket_data.gd`
- `core/resources/trinkets/*`
- `core/services/shop_offer_service.gd`
- `core/services/shop_purchase_service.gd`
- `scenes/shop/shop.gd`
- `scenes/main/controllers/main_gameplay_controller.gd`
- `autoload/game_state.gd`
- `autoload/managers/game_state_player_manager.gd`
- `features/score_bar/controllers/score_bar_meta_controller.gd`

## Findings

### 1) Strong base polymorphism is in place

`TrinketData` defines shared behavior (`get_runtime_scoring_bonus`, `apply_purchase_effects`) and specialized trinkets cleanly override those methods. This is modular and follows open/closed design.

### 2) Shop purchase path is modular but tightly coupled to `GameState` reflection

`ShopPurchaseService.apply_purchase` uses `has_method/call` checks for each action. This keeps service reuse flexible but weakens type safety and can hide integration errors until runtime.

### 3) Runtime trinket bonuses are orchestrated in controller, not view

`MainGameplayController` aggregates trinket runtime bonuses from owned trinkets, keeping runtime game logic out of UI scenes.

### 4) Duplicate metadata definitions reduce consistency

General modifier labels/rows are duplicated in:
- `TrinketData.GENERAL_MODIFIER_LABELS`
- `ScoreBarMetaController.GENERAL_MODIFIER_ROWS`

These will drift over time unless centralized.

### 5) Data key naming has partial mismatch risk

The system mixes several string-key families (`shop_*`, `base_*_value`, `mult_*_value`, `face_*_to`). Current code works, but there is no single canonical schema object.

### 6) Inventory display uses IDs, not display names

Shop inventory panel (`shop.gd`) shows `shop_item_counts` keys directly, which are item IDs. This can reduce UX clarity and complicate renaming/migration.

### 7) Event-driven architecture is only partially applied in shop flow

`GameState` emits signals for state changes, but the shop scene directly invokes state mutation methods (`spend_currency`, purchase service calling into `GameState`) rather than event bus/signals for purchase intent/result.

## Recommended Refactors (priority order)

1. **Introduce canonical modifier schema constants**
   - Create one source of truth for modifier keys + labels (e.g., `core/constants/modifier_schema.gd`).
   - Have both trinket description and score-bar meta consume it.

2. **Add a typed `ShopTransactionPort` interface**
   - Replace reflection (`has_method/call`) in `ShopPurchaseService` with a typed adapter injected by caller.
   - Keep service testable while improving compile-time safety.

3. **Split trinket ownership index from trinket instances**
   - Store owned IDs + quantity in one model and active trinket resource refs in another typed collection.
   - Enables save/load and renaming resilience.

4. **Move purchase orchestration to controller/service boundary with events**
   - Shop view emits `purchase_requested(offer_id)`.
   - Controller/service resolves and mutates model.
   - View refreshes from signals.

5. **Normalize naming typo**
   - `get_display_discription` should be renamed to `get_display_description` with backward-compatible transition.

## Quick wins

- Add one helper to map `item_id -> display_name` for inventory rendering.
- Extract a shared utility for signed modifier formatting and face/base/mult text.
- Add unit tests for `ChanceTrinketData._matches_context` and weighted offer roll edge cases (`total_weight <= 0`).

## Architectural Assessment

Overall: **Good direction, medium consistency debt**.

The current trinket data type model is fundamentally modular and extensible, but consistency can be significantly improved by centralizing modifier schema and reducing dynamic method coupling in purchase flow.
