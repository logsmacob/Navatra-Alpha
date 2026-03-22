# Event Flow Reference

This document maps the main gameplay signal flow in **Navatra**.

It focuses on how input, animation, scoring, and round progression signals trigger each other in sequence so the flow is easier to debug and extend.

---

## 1. Main gameplay flow at a glance

```text
Play button pressed
-> Hand starts play animation
-> Hand emits played_hand_ready(hand)
-> MainGameplayController resolves score + GameState updates round
-> Hand emits played_hand_finished
-> HandAnimator resets dice positions
-> Hand receives hand_reset_ready
-> Hand emits play_reset_started
-> MainGameplayController zeroes Score Bar Base, Mult, Result
-> Hand rolls non-held dice
-> EventBus emits roll_all_dice_requested
-> MainGameplayController refreshes preview/state
-> Hand emits reset_roll_finished
-> MainGameplayController clears post-play preview UI
```

```text
Roll button pressed
-> Hand consumes reroll from GameState
-> Hand rolls non-held dice
-> EventBus emits roll_all_dice_requested
-> MainGameplayController refreshes preview/state
```

```text
Round cleared in GameState
-> GameState emits round_completed
-> GameState emits reward_phase_started
-> MainRoundFlowController shows upgrade choices
-> Upgrade selected
-> MainRoundFlowController applies upgrade
-> Scene changes to shop
```

---

## 2. Signal-by-signal flow

### A. Roll flow

| Step | Emitter | Signal / Trigger | Receiver | Next action |
| --- | --- | --- | --- | --- |
| 1 | Roll button in `Hand` scene | `pressed` | `Hand._on_roll_pressed()` | Requests a reroll from `GameState`. |
| 2 | `Hand` | direct call `roll_hand()` | `HandAnimator` | Starts roll animation timing for non-held dice. |
| 3 | `Hand` | `EventBus.roll_all_dice_requested` | `MainGameplayController.handle_roll_all_dice_requested()` | Rebuilds preview math and refreshes score-bar state. |

**Important note:** the reroll refresh depends on `MainGameplayController` listening to a global `EventBus` signal instead of a hand-local signal. That works, but it is a hidden dependency for this scene flow.

### B. Play flow

| Step | Emitter | Signal / Trigger | Receiver | Next action |
| --- | --- | --- | --- | --- |
| 1 | Play button in `Hand` scene | `pressed` | `Hand._on_play_pressed()` | Disables buttons and starts the hand-play animation. |
| 2 | `HandAnimator` | animation completion (`await`) | `Hand` | `Hand` builds `DiceHand` scoring data. |
| 3 | `Hand` | `played_hand_ready(hand)` | `MainGameplayController.handle_played_hand_ready()` | Score preview is locked in and gameplay resolution begins. |
| 4 | `MainGameplayController` | direct call `GameState.process_played_hand()` | `GameState` | Round state, win/fail state, and rewards are updated. |
| 5 | `MainGameplayController` | direct call `Hand.complete_play_resolution()` | `Hand` | Emits `played_hand_finished` to start the reset phase. |
| 6 | `Hand` | `played_hand_finished` | `HandAnimator._on_hand_played_hand_finished()` | Dice return to their resting positions. |
| 7 | `HandAnimator` | `hand_reset_ready` | `Hand._on_hand_reset_ready()` | Starts the automatic post-play reroll/reset. |
| 8 | `Hand` | `play_reset_started` | `MainGameplayController.handle_play_reset_started()` | Zeroes the score-bar Base/Mult/Result columns before the automatic reroll starts. |
| 9 | `Hand` | `EventBus.roll_all_dice_requested` | `MainGameplayController.handle_roll_all_dice_requested()` | Refreshes state during the reset roll. |
| 10 | `Hand` | `reset_roll_finished` | `MainGameplayController.handle_reset_roll_finished()` | Clears score-bar preview leftovers from the played hand. |

**Important note:** this is the longest signal chain in the current project. It is still manageable, but it crosses several nodes (`Hand -> MainGameplayController -> GameState -> Hand -> HandAnimator -> Hand -> MainGameplayController`). Keep it documented whenever you extend it.

### C. Play-button hold preview flow

| Step | Emitter | Signal / Trigger | Receiver | Next action |
| --- | --- | --- | --- | --- |
| 1 | `HandButtonManager` | `play_hold_started` | `Hand._on_play_hold_started()` | Hand re-emits the event upward. |
| 2 | `Hand` | `play_hold_started` | `ScoreBar.show_preview_math()` | Preview math becomes visible while the button is held. |
| 3 | `HandButtonManager` | `play_hold_ended` | `Hand._on_play_hold_ended()` | Hand re-emits the event upward. |
| 4 | `Hand` | `play_hold_ended` | `ScoreBar.hide_preview_math()` | Preview math is hidden. |

**Important note:** `Hand` acts as a relay here. That is fine because it keeps the parent scene from reaching directly into `HandButtonManager`.

### D. Round progression flow

| Step | Emitter | Signal | Receiver | Next action |
| --- | --- | --- | --- | --- |
| 1 | `GameState` | `round_started(round_index, quota, hands, rerolls)` | `Main._on_round_started()` | Main scene resets screens and refreshes current preview/state. |
| 2 | `GameState` | `round_completed(round_index)` | `MainRoundFlowController.handle_round_completed()` | Logs/completes round-end bookkeeping. |
| 3 | `GameState` | `reward_phase_started` | `MainRoundFlowController.handle_reward_phase_started()` | Upgrade UI is refreshed and shown. |
| 4 | `HandTypeUpgradesView` | `upgrade_selected(upgrade)` | `MainRoundFlowController.handle_upgrade_selected()` | Upgrade is applied and shop scene is opened. |
| 5 | `HandTypeUpgradesView` | `reroll_requested` | `MainRoundFlowController.handle_upgrade_reroll_requested()` | Replacement upgrades are generated. |

---

## 3. Current strengths

- **Good local signal usage:** `Hand`, `HandAnimator`, and `HandButtonManager` communicate mostly through scene-local signals.
- **Reasonable controller split:** main-scene controllers already separate gameplay, round flow, and run-end flow.
- **Global state stays centralized:** `GameState` remains the runtime coordinator for round progression instead of burying that logic in UI nodes.

---

## 4. Current risks and hidden dependencies

### Hidden dependency: `EventBus.roll_all_dice_requested`

The reroll refresh path is conceptually local to the hand/main-scene gameplay flow, but it currently depends on a global event bus listener in `MainGameplayController`.

- This is fine if the signal is intended to stay project-wide.
- It becomes harder to trace because the emitter (`Hand`) and receiver (`MainGameplayController`) do not live in the same local scene wiring section.

### Longest chain: play resolution

The play-resolution path is the easiest flow to lose track of because it mixes:

- animation waits,
- signal emissions,
- `GameState` round updates,
- a controller callback into `Hand`, and
- a second animation/reset phase.

This does **not** require a full architecture rewrite, but it benefits from explicit documentation and naming.

### Coupling between `MainGameplayController` and `Hand`

`MainGameplayController` needs `Hand` to expose a method that means “gameplay resolution is finished; continue the animation chain.”

That coupling is acceptable because they belong to the same screen flow, but it should stay explicit and public. Avoid calling underscore-prefixed methods across scene/controller boundaries.

### Order-sensitive updates

Several UI refreshes depend on exact timing:

- `GameState.process_played_hand()` must happen before the final UI refresh.
- `play_reset_started` must happen before the reset roll preview/state refresh so the score-bar math visibly clears first.
- `reset_roll_finished` must happen after the reset roll.
- `ScoreBar` preview updates behave differently during `is_resolving_play_reset`.

That means future changes should preserve signal order carefully.

---

## 5. Recommended improvements (minimal, signal-friendly)

These suggestions preserve the current signal-based architecture.

1. **Keep the play flow documented close to the code.**  
   Add short comments above signals and key handlers in `Hand`, `Main`, and `MainGameplayController`.

2. **Prefer public bridge methods over cross-node private calls.**  
   If a controller must tell another node to continue a flow, use a clearly named public method such as `complete_play_resolution()` instead of calling an underscore-prefixed handler.

3. **Use scene-local signals when the event is only local.**  
   `EventBus.roll_all_dice_requested` currently works, but if this event never needs to leave the main gameplay scene, a hand-local signal would be easier to trace. This is an optional cleanup, not a required rewrite.

4. **Keep one node responsible for describing each phase.**  
   Right now the roles are mostly good:
   - `Hand` = input + local flow owner
   - `HandAnimator` = animation phase owner
   - `MainGameplayController` = gameplay resolution owner
   - `GameState` = run/round state owner

   Keep new logic inside those same boundaries.

5. **Consider a tiny state enum only if the play flow grows further.**  
   You do **not** need a full-blown state machine yet. But if you add more steps (FX, combo checks, rewards, popups), a small `HandPhase` enum or controller-level state would make debugging easier.

---

## 6. Beginner-friendly debugging checklist

When the flow breaks, check these in order:

1. Did the source node actually emit the signal?
2. Is the connection created in `_ready()` or in the `.tscn` scene file?
3. Is an `await` delaying the next step longer than expected?
4. Did `GameState` change round state before the UI refreshed?
5. Is `is_hand_ready` or `is_resolving_play_reset` blocking input/update logic?
6. Is the event using `EventBus`, making the receiver harder to find?

Useful places to log temporarily:

- `Hand._on_roll_pressed()`
- `Hand._on_play_pressed()`
- `MainGameplayController.handle_played_hand_ready()`
- `Hand._on_hand_reset_ready()`
- `MainGameplayController.handle_roll_all_dice_requested()`
- `GameState.process_played_hand()`

---

## 7. Recommended ownership answer: do you need a controller/state machine?

### Short answer

- **Controller:** yes, and you already have one in `MainGameplayController`.
- **Full state machine:** not yet.

### Why

Your current flow is a little chained, but still understandable once documented.
A full state machine would only be worth it if you start adding many more intermediate phases or conditional branches.

For now, the best improvement is:

- keep the current signal-based flow,
- document the sequence clearly,
- avoid private cross-node calls,
- and keep global-vs-local signal usage intentional.

---

## 8. Files to review when changing this flow

- `scenes/main/main.gd`
- `scenes/main/controllers/main_gameplay_controller.gd`
- `scenes/main/controllers/main_round_flow_controller.gd`
- `features/dice/hand/hand.gd`
- `features/dice/hand/hand_animator.gd`
- `features/dice/hand/hand_button_manager.gd`
- `autoload/game_state.gd`
- `autoload/event_bus.gd`
