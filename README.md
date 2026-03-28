# Navatra

## Documentation Status

- Last reviewed: 2026-03-28
- Review intent: Align wording with current architecture and event-driven conventions.


Navatra is a single-player **dice roguelite** made in **Godot 4**. Each round asks you to reduce a quota to zero before you run out of hands, while balancing rerolls and scaling your score engine.

## Gameplay Pillars

- **Quota pressure:** every round has a target score to clear.
- **Shared rerolls:** rerolls are a scarce round-level resource.
- **Hand optimization:** each play is evaluated as the best valid hand type.
- **Scaling progression:** rounds become harder; upgrades improve your scoring potential.

## Core Round Loop

1. Start round with quota, hands, and rerolls.
2. Roll 5 dice and optionally hold/reroll.
3. Submit hand for evaluation and score calculation.
4. Score is subtracted from quota.
5. Clear quota to enter rewards/shop and continue to next round.
6. Fail if hands are exhausted before quota reaches zero.

## Scoring Model

Navatra uses additive multiplier stacking:

```text
Hand Base = HandType_Base + Sum(Scoring Dice Faces) + Trinket/Upgrade Base Bonuses
Total Mult = 1 + HandType_Mult + Trinket/Upgrade Mult Bonuses
Final Score = Hand Base × Total Mult
```

## Project Structure

- `autoload/` — global orchestration (`GameState`, `EventBus`) and run/player managers.
- `core/` — data models, resources, scoring/evaluation services.
- `features/` — reusable gameplay features (dice, hand evaluation, upgrades, score bar).
- `scenes/` — top-level screens and flow controllers.
- `docs/` — architecture and developer-facing documentation.

## Getting Started (Development)

### Requirements

- Godot 4.6 (Forward Plus renderer)

### Run locally

1. Open this repository folder in Godot.
2. Run the project (`F5`) from the editor.
3. Default boot scene is configured in `project.godot`.

### Useful Autoloads

- `GameState`: owns round progression, currency, run state, and player hand state.
- `EventBus`: signal hub for decoupled cross-feature events.

## Documentation

- Architecture layers: `docs/architecture/layers.md`
- Development guidelines: `docs/development/contributing.md`
- Itch/store marketing copy kit: `docs/marketing/itch_page_kit.md`

## Current Balance Defaults

- Base quota curve: exponential growth managed by `RoundProgressionService`.
- Dice per hand: 5d6 by default.
- Rerolls: round-level limited resource.
- Run progression and round lifecycle managed by `GameStateRunManager`.

## License

No license file is currently included. Add one before public distribution.
