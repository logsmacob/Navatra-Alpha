# Godot Large Project Best Practices (UI + Logic Heavy)

## Documentation Status

- Last reviewed: 2026-03-28
- Review intent: Align wording with current architecture and event-driven conventions.


_A practical internal guide for Godot 4.5–4.6 style projects._

## 1) Project Architecture

### Use feature-based folder structure

Prefer organizing by feature rather than by file type.

```text
/features/
    inventory/
        inventory_ui.tscn
        inventory_logic.gd
    dialogue/
    combat/
/core/
    game_manager.gd
    event_bus.gd
/ui/
    theme/
    shared/
```

Why:
- Keeps UI, logic, and assets together
- Scales better with larger teams
- Makes refactors safer and faster

### Treat each scene as a feature unit

Each major feature should be self-contained.

```text
InventoryScene
├── InventoryUI (Control)
├── InventoryController (Node)
```

UI and logic should never be tightly coupled.

## 2) UI Architecture (Critical for UI-heavy games)

### Separate UI from logic

UI scripts should display data and emit signals only.

Bad:

```gdscript
# inventory_ui.gd
func _on_button_pressed():
    player.add_item(item)
```

Good:

```gdscript
# inventory_ui.gd
signal item_clicked(item_id)

func _on_button_pressed():
    item_clicked.emit(item_id)

# inventory_controller.gd
func _on_ui_item_clicked(item_id):
    inventory.add(item_id)
```

### Use signals for system communication

Use signals for:
- UI → game logic
- Game logic → UI updates
- Cross-system communication

### Use a central EventBus when scale grows

```gdscript
# event_bus.gd (autoload)
signal inventory_updated
signal dialogue_started
signal currency_changed
```

Usage:

```gdscript
EventBus.inventory_updated.emit()
```

### Use Control nodes and containers correctly

Preferred tools:
- `MarginContainer`
- `VBoxContainer` / `HBoxContainer`
- `GridContainer`

This is essential for resizing, aspect-ratio changes, and mobile safe areas.

### Avoid absolute positioning

Use anchors + containers for responsive layouts.

### Use a global Theme

- Centralize styling in a shared Theme
- Avoid per-node visual overrides when possible
- Define reusable styles for controls

## 3) Code Architecture

### Follow single responsibility

Each script should do one job.

| Script type | Responsibility |
| --- | --- |
| UI script | Display + emit signals |
| Controller | Handle logic and orchestration |
| Data model | Store state/data |

### Use `class_name` for key types

```gdscript
class_name Inventory
```

Benefits:
- Less fragile than string/path-based loading
- Safer refactors
- Better editor discoverability

### Prefer composition over inheritance

Bad:

```text
Enemy → FlyingEnemy → BossEnemy → FireBossEnemy
```

Good:

```text
Enemy
├── MovementComponent
├── AttackComponent
├── HealthComponent
```

### Use autoloads carefully

Good autoload candidates:
- `GameManager`
- `SaveSystem`
- `EventBus`

Avoid turning autoloads into a dumping ground for unrelated systems.

## 4) Data Management

### Use Resources for static/configurable data

```gdscript
class_name ItemData
extends Resource

@export var name: String
@export var icon: Texture2D
```

Benefits:
- Inspector-editable
- Reusable
- Serializable

### Separate data, logic, and presentation

- Inventory data → Resource / Array / model
- Inventory logic → service/controller
- Inventory UI → scene/control scripts

## 5) Scene Instancing and Loading

### Prefer exported `PackedScene`

```gdscript
@export var item_scene: PackedScene

var item = item_scene.instantiate()
```

Avoid hardcoded scene paths where possible.

### Lazy-load heavy UI

```gdscript
if not inventory_scene:
    inventory_scene = preload("res://...").instantiate()
```

## 6) Performance (UI-heavy projects)

- Minimize `_process()` use for UI and logic
- Prefer signals/events over polling
- Avoid unnecessarily deep node trees
- Toggle visibility instead of recreating frequently used UI
- Batch UI refreshes and avoid per-frame updates

## 7) State Management

### Use explicit state machines where useful

Example flows:
- Main Menu
- Settings Menu
- Pause Menu

### Avoid uncontrolled global mutation

Preferred flow:

```text
UI → Controller → Data/System → Event → UI refresh
```

## 8) Naming Conventions

| Type | Convention |
| --- | --- |
| Scenes | `snake_case.tscn` |
| Scripts | `snake_case.gd` |
| Classes | `PascalCase` (`class_name`) |
| Signals | Past tense (`item_selected`) |

## 9) Debugging and Scaling

- Build debug tooling early (overlay/logging/state inspector)
- Create small isolated test scenes to validate systems quickly

## 10) Workflow Tips

### Reusable base scenes

Example:

```text
BaseScreen (MarginContainer)
    ↓
InventoryScreen
SettingsScreen
```

### Avoid tight coupling between gameplay systems and UI

Bad:

```text
UI directly accesses Player
```

Good:

```text
UI → Event → System → Player
```

## 11) Recommended Godot-Friendly Patterns

- Event Bus pattern
- MVC-lite (UI / Controller / Data)
- Node-based component system
- Signal-driven architecture

## Golden Rules (TL;DR)

1. UI emits signals; UI does not own gameplay logic
2. Build scenes as modular feature units
3. Avoid hardcoded paths
4. Prefer composition over inheritance
5. Use Resources for data
6. Prefer signal-driven updates over polling
7. Keep systems loosely coupled
