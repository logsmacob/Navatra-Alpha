extends Node

## Hand currency bonus service script: coordinates this part of the game's behavior.
class_name HandCurrencyBonusService

func get_scoring_material_currency_bonus(scoring_dice: Array[DieUI]) -> int:
	var total_bonus := 0
	for die_ui: DieUI in scoring_dice:
		if die_ui == null or die_ui.die == null or die_ui.die.data == null:
			continue
		var material := str(die_ui.die.data.material)
		total_bonus += int(GameState.MATERIAL_CURRENCY_BONUS.get(material, 0))
	return total_bonus
