extends Control

signal upgrade_selected(upgrade: HandTypeUpgradeDefinition)
signal reroll_requested

@onready var upgrades_container: VBoxContainer = $VBoxContainer/UpgradeList
@onready var reroll_button: Button = $VBoxContainer/RerollButton

func _ready() -> void:
	reroll_button.pressed.connect(_on_reroll_pressed)

func show_upgrades(upgrades: Array[HandTypeUpgradeDefinition]) -> void:
	for child in upgrades_container.get_children():
		child.queue_free()

	for upgrade in upgrades:
		if upgrade == null:
			continue

		var button := Button.new()
		button.text = "%s\n%s" % [upgrade.get_title(), upgrade.get_description()]
		button.custom_minimum_size = Vector2(0, 110)
		button.pressed.connect(_on_upgrade_pressed.bind(upgrade))
		upgrades_container.add_child(button)

	visible = true

func _on_upgrade_pressed(upgrade: HandTypeUpgradeDefinition) -> void:
	upgrade_selected.emit(upgrade)

func _on_reroll_pressed() -> void:
	reroll_requested.emit()
