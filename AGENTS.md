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
- Player stats
- Inventory data
- Game state

---

### View (UI)
- Displays data to the player
- Handles visual updates only
- Must NOT contain gameplay logic

Examples:
- HUD
- Menus
- Health bars

---

### ViewModel / Controller (Glue Layer)
- Connects Model and View
- Transforms data for UI
- Listens to events and updates UI

Examples:
- UI controllers
- Scene coordinators

---

## Event-Driven Rules

- Use signals for communication between systems
- Avoid direct method calls across systems
- Systems should emit events instead of calling each other

### Example

```gdscript
# BAD (tight coupling)
player.take_damage(10)
ui.update_health(player.health)

# GOOD (event-driven)
player.emit_signal("damaged", 10)