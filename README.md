# Navatra

Navatra is a single-player dice roguelite built around quota pressure, limited reroll resources, and additive multiplier engine building.

There is no opponent. The player’s only objective is to reduce an exponentially scaling quota to zero before running out of playable hands.

Each round is a constrained optimization problem: limited rerolls, limited hands, and escalating score requirements.

## Core Gameplay Overview

Navatra combines:

- Dice hand evaluation (Yahtzee-style structure)
- Shared reroll resource management
- Additive multiplier stacking
- Exponential quota scaling
- Roguelite trinket progression

The goal each round:

> Reduce the quota to zero before running out of playable hands.

Failure ends the run.

## Round Structure

At the start of each round:

- 5 six-sided dice (5d6)
- A fixed number of playable hands
- A quota value
- **3 total rerolls shared across the entire round**

Important:

- The player gets an initial roll for each hand.
- Rerolls are limited to **3 total per round**, not per hand.
- Rerolls can be used on any hand, but once spent, they are gone for the rest of the round.

This creates long-term decision pressure: use rerolls early for consistency, or save them to salvage a critical final hand.

## Per-Hand Flow

1. Roll all 5 dice (initial roll).
2. Choose which dice to hold.
3. Optionally spend rerolls (if any remain for the round).
4. Finalize the hand.
5. Evaluate the best valid hand type.
6. Calculate score.
7. Subtract score from quota.

If:

- Quota > 0 → Continue to next hand.
- Quota ≤ 0 → Round complete → Enter shop.
- No playable hands remain and quota > 0 → Run ends.

## Scoring System

Each hand type defines:

- HandType_Base (flat value)
- HandType_Mult (additive multiplier)

Only dice used to form the hand contribute their face values to base.

### Formula

```text
Hand Base = HandType_Base + Sum(Scoring Dice Faces)

Total Mult = 1 + HandType_Mult + Sum(All Trinket Mult Bonuses)

Final Score = Hand Base × Total Mult
```

Rules:

- Multiplier stacking is additive.
- Multiplier always starts at 1.
- Only scoring dice contribute to base.
- Hand types are reusable within the round.

This creates three scaling dimensions:

1. Hand rarity
2. Dice face variance
3. Engine multiplier growth

## Reroll System Identity

Because rerolls are shared per round:

- Early hands create opportunity cost.
- Late hands become high-pressure.
- Bad variance can no longer be brute-forced every hand.

This system strongly increases strategic depth compared to per-hand rerolls.

## Quota Scaling

Quota increases exponentially each round.

Example structure:

```text
Quota_n = BaseQuota × GrowthRate^Round
```

The player must scale their engine fast enough to outpace this curve.

If multiplier growth stalls, the run collapses.

## Shop Phase

After completing a round:

- Player enters a shop.
- Shop offers randomized trinkets from a deck-style pool.
- Trinkets persist for the duration of the run.

Trinkets can:

- Add additive multiplier bonuses
- Increase hand-type base values
- Modify dice behavior
- Alter probability
- Add scaling mechanics

## Core Design Identity

Navatra is a resource-constrained scoring roguelite defined by:

- Shared reroll scarcity
- Reusable hand types
- Additive multiplier stacking
- Exponential quota escalation

The tension is not in defeating an opponent.

The tension is in surviving the math.

## Failure Condition

The run ends when:

- Playable hands are exhausted before the quota reaches zero.

---

If you want to refine further, the next big balance levers to define are:

- How many playable hands per round?
- Does that number scale?
- Do rerolls ever increase via trinkets?

## Foundation Defaults (Implemented)

To lock in a strong foundation, the project now has explicit runtime state and balance defaults:

- **Run state** tracks current round and persistent trinkets.
- **Round state** tracks quota, hands remaining, and rerolls remaining.
- **Hand scoring table** provides base and additive multiplier values per hand type.
- **Score calculator** applies:
  - `Hand Base = HandType_Base + Sum(Scoring Dice Faces) + Trinket Base Bonuses`
  - `Total Mult = 1 + HandType_Mult + Trinket Mult Bonuses`
  - `Final Score = Hand Base × Total Mult`
- **Quota scaling** defaults to exponential growth:
  - `Quota_n = 100 × 1.45^(Round-1)`
- **Hands per round** currently scale slowly:
  - Base 4 hands, +1 hand every 3 rounds.
- **Rerolls** default to 3 per round, with optional trinket-based increases.

These defaults are intentionally centralized so they can be tuned without rewriting gameplay flow.

## Developer API Notes (Dice)

To make scripting simpler while building, use this flow:

1. Create a die with `DieInstance.create_standard_d6()`.
2. Assign it to UI with `DieUI.set_die(die)`.
3. Roll through `DieUI.roll_if_not_selected()` so hold/selection state is respected.

Helpful APIs:
- `DieInstance.configure_with_sequential_faces(face_count)`: builds an N-sided die with values `1..N`.
- `DieInstance.set_face_values(values)`: custom face values (array size must match face count).
- `DieInstance.roll()`: returns `FaceData` and emits `rolled(face)`.
- `DieUI.die_rolled(face)`: UI-level signal emitted after successful rolls.

This gives you a clean default path while still allowing custom dice behavior when needed.

## Modularity Notes (New)

To keep future changes safe and readable, the project now follows this split:

- `GameState` (autoload): owns round/run rules and mutable gameplay state.
- `EventBus` (autoload): global decoupled events between feature modules.
- `Hand` scene: owns only hand-level UI behavior (spawn dice, reroll interactions, play hand).
- `DieUI`: owns single-die interaction state (held vs not held) and view updates.
- `Main` scene script: orchestration layer that reacts to hand events and updates game state.

### Practical extension strategy

When adding a mechanic, use this order:

1. Add/adjust rules in `autoload/game_state.gd`.
2. Add cross-feature signals in `autoload/event_bus.gd` only if needed.
3. Keep scene scripts thin (UI + signal wiring).
4. Keep scoring/evaluation logic in one place (currently `scenes/main.gd`, can be moved to a dedicated scorer next).

This makes balancing and new features (shop, trinkets, custom dice) easier without rewriting UI code.
