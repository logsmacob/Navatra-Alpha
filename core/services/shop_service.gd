class_name ShopService

# NOTE: Minimal in-code trinket pool until data resources are added.
static func get_offer_pool() -> Array[TrinketModel]:
	return [
		TrinketModel.new("mult_chip", "Multiplier Chip", 0.2),
		TrinketModel.new("pair_tome", "Pair Tome", 0.0, 0, {HandEvaluatorModel.HandType.ONE_PAIR: 4}),
		TrinketModel.new("spare_roll", "Spare Roll", 0.0, 1),
		TrinketModel.new("straight_seal", "Straight Seal", 0.15, 0, {HandEvaluatorModel.HandType.STRAIGHT: 6})
	]

static func get_random_offers(count: int) -> Array[TrinketModel]:
	var pool := get_offer_pool()
	pool.shuffle()
	var to_take := mini(max(0, count), pool.size())
	var offers: Array[TrinketModel] = []
	for i in range(to_take):
		offers.append(pool[i])
	return offers
