extends Control
## Hand type upgrades script: coordinates this part of the game's behavior.
class_name HandTypeUpgradesView

signal upgrade_selected(upgrade: HandTypeUpgradeDefinition)
signal reroll_requested

@onready var upgrades_container: VBoxContainer = $VBoxContainer/UpgradeList
@onready var reroll_button: Button = $VBoxContainer/RerollButton

@export var buttons: Array[Button]

func _ready() -> void:
	reroll_button.pressed.connect(_on_reroll_pressed)

func show_upgrades(upgrades: Array[HandTypeUpgradeDefinition]) -> void:
	for button in buttons:
		button.visible = false
		for connection in button.pressed.get_connections():
			button.pressed.disconnect(connection.callable)

	var i = 0
	for upgrade in upgrades:
		if upgrade == null or i >= buttons.size():
			continue

		var button := buttons[i]
		i += 1
		button.text = "%s\n%s" % [upgrade.get_title(), upgrade.get_description()]
		button.visible = true
		button.pressed.connect(_on_upgrade_pressed.bind(upgrade))

	get_tree().paused = true
	visible = true

func set_reroll_price(price: int, can_afford: bool) -> void:
	reroll_button.text = "Reroll (%d)" % max(price, 0)
	reroll_button.disabled = not can_afford

func _on_upgrade_pressed(upgrade: HandTypeUpgradeDefinition) -> void:
	get_tree().paused = false
	upgrade_selected.emit(upgrade)

func _on_reroll_pressed() -> void:
	reroll_requested.emit()
